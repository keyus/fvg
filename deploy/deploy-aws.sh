#!/usr/bin/env bash
#
# uilines 一键部署到 AWS（单机版：EC2 + Docker + 可选 Caddy HTTPS + 可选 RDS MySQL）
#
#   cp deploy/deploy.env.example deploy/deploy.env   # 填参数
#   bash deploy/deploy-aws.sh --plan                 # 只看将创建什么，不动 AWS
#   bash deploy/deploy-aws.sh                        # 真正部署
#   bash deploy/deploy-aws.sh --destroy              # 删除本脚本创建的资源
#
# 幂等：重复执行会复用已创建的资源（状态记录在 deploy/.deploy-state.env）。
# 兼容 macOS 自带 bash 3.2（不使用 bash4 特性）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/deploy.env}"
STATE_FILE="$SCRIPT_DIR/.deploy-state.env"
SSH_OPTS_BASE="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$SCRIPT_DIR/.known_hosts -o ConnectTimeout=10 -o LogLevel=ERROR"

MODE="deploy"
for arg in "$@"; do
  case "$arg" in
    --plan) MODE="plan" ;;
    --destroy) MODE="destroy" ;;
    -h | --help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "未知参数：${arg}（支持 --plan / --destroy）" >&2
      exit 2
      ;;
  esac
done

log() { printf '\033[1;36m[deploy]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
die() {
  printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
  exit 1
}

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "缺少命令 $1：$2"; }

state_get() {
  [ -f "$STATE_FILE" ] || return 0
  grep "^$1=" "$STATE_FILE" 2>/dev/null | tail -1 | cut -d= -f2- || true
}

state_set() {
  touch "$STATE_FILE"
  grep -v "^$1=" "$STATE_FILE" >"$STATE_FILE.tmp" 2>/dev/null || true
  printf '%s=%s\n' "$1" "$2" >>"$STATE_FILE.tmp"
  mv "$STATE_FILE.tmp" "$STATE_FILE"
  chmod 600 "$STATE_FILE"
}

rand_secret() { openssl rand -base64 32 | tr -d '\n=+/' | cut -c1-40; }

# ---------------------------------------------------------------- 配置
if [ "$MODE" != "plan" ] && [ ! -f "$CONFIG_FILE" ]; then
  die "找不到配置文件 ${CONFIG_FILE}：先 cp deploy/deploy.env.example deploy/deploy.env 并填写"
fi

# shellcheck disable=SC1090
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

AWS_REGION="${AWS_REGION:-ap-northeast-1}"
AWS_PROFILE="${AWS_PROFILE:-}"
INSTANCE_NAME="${INSTANCE_NAME:-uilines}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t4g.medium}"
INSTANCE_ARCH="${INSTANCE_ARCH:-arm64}"
KEY_NAME="${KEY_NAME:-${INSTANCE_NAME}-deploy}"
SSH_ALLOW_CIDR="${SSH_ALLOW_CIDR:-}"
DOMAIN="${DOMAIN:-}"
ACME_EMAIL="${ACME_EMAIL:-}"
DB_MODE="${DB_MODE:-rds}"
DB_NAME="${DB_NAME:-uilines}"
DB_USER="${DB_USER:-uilines}"
RDS_CLASS="${RDS_CLASS:-db.t4g.micro}"
RDS_STORAGE="${RDS_STORAGE:-20}"
RDS_STORAGE_TYPE="${RDS_STORAGE_TYPE:-gp3}"
IMAGE_MODE="${IMAGE_MODE:-local}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECR_REPO="${ECR_REPO:-${INSTANCE_NAME}}"
IAM_ROLE_NAME="${IAM_ROLE_NAME:-${INSTANCE_NAME}-app}"
CREATE_DNS="${CREATE_DNS:-1}"
SEED_DEMO_DATA="${SEED_DEMO_DATA:-0}"
GEOIP_LOOKUP="${GEOIP_LOOKUP:-0}"
SUPPORT_EMAIL="${SUPPORT_EMAIL:-}"
SUPPORT_PHONE="${SUPPORT_PHONE:-}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@${INSTANCE_NAME}.dev}"
APP_DIR="/srv/${INSTANCE_NAME}"

[ "$DB_MODE" = "rds" ] || [ "$DB_MODE" = "local" ] || die "DB_MODE 只能是 rds 或 local"
[ "$IMAGE_MODE" = "local" ] || [ "$IMAGE_MODE" = "instance" ] ||
  die "IMAGE_MODE 只能是 local（本机构建 + ECR，推荐）或 instance（在服务器上构建）"
if [ -n "$DOMAIN" ] && [ -z "$ACME_EMAIL" ]; then
  die "配置了 DOMAIN 就必须给 ACME_EMAIL（申请 Let's Encrypt 证书用）"
fi

if [ -z "$SSH_ALLOW_CIDR" ]; then
  MY_IP="$(curl -fsS --max-time 8 https://checkip.amazonaws.com 2>/dev/null | tr -d '\n' || true)"
  [ -n "$MY_IP" ] || die "无法自动获取本机公网 IP，请在 deploy.env 里显式设置 SSH_ALLOW_CIDR"
  SSH_ALLOW_CIDR="$MY_IP/32"
fi

# 复用已有随机密钥（重复部署时不要轮换，否则会话失效 / 连不上库）
BETTER_AUTH_SECRET="$(state_get BETTER_AUTH_SECRET)"
CRON_SECRET="$(state_get CRON_SECRET)"
DB_PASSWORD="$(state_get DB_PASSWORD)"
MYSQL_ROOT_PASSWORD="$(state_get MYSQL_ROOT_PASSWORD)"
ADMIN_PASSWORD="$(state_get ADMIN_PASSWORD)"
[ -n "$BETTER_AUTH_SECRET" ] || BETTER_AUTH_SECRET="$(rand_secret)$(rand_secret)"
[ -n "$CRON_SECRET" ] || CRON_SECRET="$(rand_secret)"
[ -n "$DB_PASSWORD" ] || DB_PASSWORD="$(rand_secret)"
[ -n "$MYSQL_ROOT_PASSWORD" ] || MYSQL_ROOT_PASSWORD="$(rand_secret)"
[ -n "$ADMIN_PASSWORD" ] || ADMIN_PASSWORD="$(rand_secret)"

WEB_SG_NAME="${INSTANCE_NAME}-web"
DB_SG_NAME="${INSTANCE_NAME}-db"
RDS_ID="${INSTANCE_NAME}-mysql"
SUBNET_GROUP="${INSTANCE_NAME}-subnets"
PEM_FILE="$SCRIPT_DIR/keys/${KEY_NAME}.pem"

# ---------------------------------------------------------------- 计划模式
if [ "$MODE" = "plan" ]; then
  cat <<EOF
即将执行（--plan 只打印，不调用 AWS）：

  区域 / 实例      : $AWS_REGION / $INSTANCE_TYPE ($INSTANCE_ARCH)  名称: $INSTANCE_NAME
  SSH 来源         : $SSH_ALLOW_CIDR        Key: $KEY_NAME
  访问地址         : $([ -n "$DOMAIN" ] && echo "https://${DOMAIN}（Caddy 自动证书）" || echo "http://<弹性IP>（HTTP 测试模式）")
  数据库           : $([ "$DB_MODE" = "rds" ] && echo "RDS MySQL 8.4 $RDS_CLASS ${RDS_STORAGE}GB ${RDS_STORAGE_TYPE}（私有，仅应用可访问）" || echo "同机 MySQL 8.4 容器（compose 内网）")
  应用镜像         : $([ "$IMAGE_MODE" = "local" ] && echo "本机构建（linux/${INSTANCE_ARCH}）→ 推 ECR → 服务器拉取" || echo "在服务器上构建（需要更多内存）")
  域名解析         : $([ -n "$DOMAIN" ] && [ "$CREATE_DNS" = "1" ] && echo "自动在 Route53 把 ${DOMAIN} 指向弹性 IP" || echo "手动解析 / 暂不解析")
  种子数据         : $([ "$SEED_DEMO_DATA" = "0" ] && echo "干净库（跳过模拟会员/演示订单等）" || echo "包含演示会员与订单")
  管理员账号       : ${ADMIN_EMAIL}（密码在部署结束时打印）

将创建的资源：
  - 安全组 ${WEB_SG_NAME}（22 来源 ${SSH_ALLOW_CIDR}，80/443 公开）
$([ "$DB_MODE" = "rds" ] && printf '  - 安全组 %s（3306 仅来自 %s）\n' "$DB_SG_NAME" "$WEB_SG_NAME")
$([ "$DB_MODE" = "rds" ] && printf '  - RDS 实例 %s（MySQL 8.4, %s）\n' "$RDS_ID" "$RDS_CLASS")
  - IAM 角色 ${IAM_ROLE_NAME}（SSM 会话 + ECR 只读，挂到实例上）
$([ "$IMAGE_MODE" = "local" ] && printf '  - ECR 仓库 %s（存放本机构建好的镜像）\n' "$ECR_REPO")
  - EC2 实例 ${INSTANCE_NAME}（${INSTANCE_TYPE}）+ 弹性 IP + 密钥对 $KEY_NAME
  - 应用：${APP_DIR}（Docker 镜像在本机构建后推送部署）

预计费用（${AWS_REGION}，量级参考，按小时计费）：EC2 \$$([ "$INSTANCE_TYPE" = "t4g.medium" ] && echo "30-40" || echo "15-25")/月
  + 30GB gp3 磁盘 ≈ \$3/月 + 弹性 IP（挂机免费）
$([ "$DB_MODE" = "rds" ] && echo "  + RDS db.t4g.micro ≈ \$15-20/月（20GB gp3 + 7 天备份）" || echo "  + 同机 MySQL 容器 \$0（共用实例磁盘）")
$([ -n "$DOMAIN" ] && echo "  + 无额外（Caddy 证书免费）" || echo "  + 无额外（暂用 HTTP）")
  + ECR 镜像存储通常 < \$1/月
EOF
  exit 0
fi

# ---------------------------------------------------------------- AWS CLI
require_cmd aws "brew install awscli"

if [ -n "$AWS_PROFILE" ]; then
  aws() { command aws --region "$AWS_REGION" --profile "$AWS_PROFILE" "$@"; }
else
  aws() { command aws --region "$AWS_REGION" "$@"; }
fi
export -f aws 2>/dev/null || true

log "校验 AWS 凭据…"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
[ -n "$ACCOUNT_ID" ] && [ "$ACCOUNT_ID" != "None" ] ||
  die "AWS 凭据不可用：先执行 aws configure（或 aws sso login），必要时在 deploy.env 里设 AWS_PROFILE"
log "账号 $ACCOUNT_ID / 区域 $AWS_REGION"

# 首次运行生成、之后复用：这些密钥一旦轮换会导致会话失效 / 连不上库
state_set BETTER_AUTH_SECRET "$BETTER_AUTH_SECRET"
state_set CRON_SECRET "$CRON_SECRET"
state_set DB_PASSWORD "$DB_PASSWORD"
state_set MYSQL_ROOT_PASSWORD "$MYSQL_ROOT_PASSWORD"
state_set ADMIN_PASSWORD "$ADMIN_PASSWORD"

ask_confirm() {
  printf '\033[1;33m%s\033[0m [y/N] ' "$1"
  read -r answer
  case "$answer" in
    y | Y | yes | YES) return 0 ;;
    *) die "已取消" ;;
  esac
}

# ---------------------------------------------------------------- destroy
if [ "$MODE" = "destroy" ]; then
  warn "将删除本脚本创建的资源（RDS 会先做最终快照）："
  warn "  EC2 $(state_get INSTANCE_ID) / EIP $(state_get EIP_ALLOC_ID) / SG $WEB_SG_NAME,$DB_SG_NAME / RDS $RDS_ID"
  [ "${DESTROY_CONFIRM:-}" = "yes" ] || ask_confirm "确认继续？"

  INSTANCE_ID="$(state_get INSTANCE_ID)"
  if [ -n "$INSTANCE_ID" ]; then
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" >/dev/null || true
    log "已请求终止 EC2 ${INSTANCE_ID}（EBS 随实例删除）"
  fi
  ALLOC_ID="$(state_get EIP_ALLOC_ID)"
  if [ -n "$ALLOC_ID" ]; then
    aws ec2 release-address --allocation-id "$ALLOC_ID" >/dev/null 2>&1 || true
    log "已释放弹性 IP"
  fi
  if aws rds describe-db-instances --db-instance-identifier "$RDS_ID" >/dev/null 2>&1; then
    aws rds delete-db-instance --db-instance-identifier "$RDS_ID" \
      --final-db-snapshot-identifier "${RDS_ID}-final-$(date +%Y%m%d%H%M)" \
      --delete-automated-backups >/dev/null
    log "已请求删除 RDS（保留最终快照）"
  fi
  for sg in "$WEB_SG_NAME" "$DB_SG_NAME"; do
    SG="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$sg" \
      --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)"
    if [ -n "$SG" ] && [ "$SG" != "None" ]; then
      aws ec2 delete-security-group --group-id "$SG" >/dev/null 2>&1 || warn "安全组 $sg 仍在被占用，稍后可手动删除"
    fi
  done
  # Route53：删掉本脚本写入的 A 记录
  ZONE_ID="$(state_get HOSTED_ZONE_ID)"
  if [ -n "$ZONE_ID" ] && [ -n "$DOMAIN" ]; then
    for RECORD in "$DOMAIN" "www.$DOMAIN"; do
      aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"${RECORD}\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$(state_get PUBLIC_IP)\"}]}}]}" >/dev/null 2>&1 ||
        warn "DNS 记录 ${RECORD} 删除失败（可能已改过），请手动确认"
    done
  fi
  # ECR 镜像仓库
  if aws ecr describe-repositories --repository-names "$ECR_REPO" >/dev/null 2>&1; then
    aws ecr delete-repository --repository-name "$ECR_REPO" --force >/dev/null
    log "已删除 ECR 仓库 $ECR_REPO"
  fi
  # IAM：先摘角色再删实例配置文件与角色
  if aws iam get-instance-profile --instance-profile-name "$IAM_ROLE_NAME" >/dev/null 2>&1; then
    aws iam remove-role-from-instance-profile --instance-profile-name "$IAM_ROLE_NAME" \
      --role-name "$IAM_ROLE_NAME" >/dev/null 2>&1 || true
    aws iam delete-instance-profile --instance-profile-name "$IAM_ROLE_NAME" >/dev/null 2>&1 || true
  fi
  if aws iam get-role --role-name "$IAM_ROLE_NAME" >/dev/null 2>&1; then
    for policy in AmazonSSMManagedInstanceCore AmazonEC2ContainerRegistryReadOnly; do
      aws iam detach-role-policy --role-name "$IAM_ROLE_NAME" \
        --policy-arn "arn:aws:iam::aws:policy/$policy" >/dev/null 2>&1 || true
    done
    aws iam delete-role --role-name "$IAM_ROLE_NAME" >/dev/null 2>&1 || warn "IAM 角色删除失败（可能仍被占用）"
    log "已清理 IAM 角色 $IAM_ROLE_NAME"
  fi
  log "销毁流程完成（数据库快照保留在 RDS 里）"
  exit 0
fi

# ---------------------------------------------------------------- 预检
require_cmd docker "安装 Docker Desktop"
require_cmd ssh "系统自带"
require_cmd tar "系统自带"
require_cmd openssl "系统自带"

log "=========== 步骤 1/11：网络与镜像 ==========="
VPC_ID="$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' --output text)"
[ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ] ||
  die "该区域没有默认 VPC：请在 deploy.env 里换区域，或先创建默认 VPC"
AMI_PARAM="/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-${INSTANCE_ARCH}"
AMI_ID="$(aws ssm get-parameter --name "$AMI_PARAM" --query 'Parameter.Value' --output text)"
log "VPC $VPC_ID / AMI $AMI_ID"

log "=========== 步骤 2/11：SSH 密钥 ==========="
mkdir -p "$SCRIPT_DIR/keys"
chmod 700 "$SCRIPT_DIR/keys"
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" >/dev/null 2>&1; then
  [ -f "$PEM_FILE" ] ||
    die "AWS 里已有密钥对 ${KEY_NAME}，但本地缺 $PEM_FILE —— 把对应私钥放到该路径，或改 KEY_NAME 参数"
  log "复用已有密钥对 $KEY_NAME"
else
  aws ec2 create-key-pair --key-name "$KEY_NAME" --query 'KeyMaterial' --output text >"$PEM_FILE"
  chmod 600 "$PEM_FILE"
  log "已创建密钥对并保存私钥到 $PEM_FILE"
fi

log "=========== 步骤 3/11：安全组 ==========="
find_sg() {
  aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$1" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true
}
WEB_SG="$(find_sg "$WEB_SG_NAME")"
if [ -z "$WEB_SG" ] || [ "$WEB_SG" = "None" ]; then
  WEB_SG="$(aws ec2 create-security-group --group-name "$WEB_SG_NAME" \
    --description "uilines web (80/443/ssh)" --vpc-id "$VPC_ID" \
    --query 'GroupId' --output text)"
  log "创建安全组 $WEB_SG_NAME ($WEB_SG)"
fi
allow_ingress() { # $1=sg $2=proto $3=port $4=cidr
  aws ec2 authorize-security-group-ingress --group-id "$1" --protocol "$2" \
    --port "$3" --cidr "$4" >/dev/null 2>&1 ||
    warn "入站规则已存在：$1 $2/$3 $4"
}
allow_ingress "$WEB_SG" tcp 22 "$SSH_ALLOW_CIDR"
allow_ingress "$WEB_SG" tcp 80 "0.0.0.0/0"
allow_ingress "$WEB_SG" tcp 443 "0.0.0.0/0"

DB_SG=""
if [ "$DB_MODE" = "rds" ]; then
  DB_SG="$(find_sg "$DB_SG_NAME")"
  if [ -z "$DB_SG" ] || [ "$DB_SG" = "None" ]; then
    DB_SG="$(aws ec2 create-security-group --group-name "$DB_SG_NAME" \
      --description "uilines rds (3306 from web sg)" --vpc-id "$VPC_ID" \
      --query 'GroupId' --output text)"
    log "创建安全组 $DB_SG_NAME ($DB_SG)"
  fi
  aws ec2 authorize-security-group-ingress --group-id "$DB_SG" \
    --protocol tcp --port 3306 --source-group "$WEB_SG" >/dev/null 2>&1 ||
    warn "数据库安全组规则已存在"
fi

log "=========== 步骤 4/11：IAM 角色（SSM 会话 + ECR 只读） ==========="
ROLE_ARN=""
if aws iam get-role --role-name "$IAM_ROLE_NAME" >/dev/null 2>&1; then
  ROLE_ARN="$(aws iam get-role --role-name "$IAM_ROLE_NAME" --query 'Role.Arn' --output text)"
  log "复用已有角色 $IAM_ROLE_NAME"
else
  ROLE_ARN="$(aws iam create-role --role-name "$IAM_ROLE_NAME" \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
    --query 'Role.Arn' --output text)"
  aws iam attach-role-policy --role-name "$IAM_ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  aws iam attach-role-policy --role-name "$IAM_ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
  log "已创建角色 $IAM_ROLE_NAME 并授予 SSM / ECR 只读"
fi
if ! aws iam get-instance-profile --instance-profile-name "$IAM_ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-instance-profile --instance-profile-name "$IAM_ROLE_NAME" >/dev/null
  aws iam add-role-to-instance-profile --instance-profile-name "$IAM_ROLE_NAME" \
    --role-name "$IAM_ROLE_NAME" >/dev/null
  log "已创建实例配置文件 ${IAM_ROLE_NAME}（IAM 生效需要约 10 秒）"
  sleep 10
fi

log "=========== 步骤 5/11：数据库 ==========="
if [ "$DB_MODE" = "rds" ]; then
  if aws rds describe-db-instances --db-instance-identifier "$RDS_ID" >/dev/null 2>&1; then
    log "RDS $RDS_ID 已存在，直接复用"
  else
    SUBNETS="$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
      --query 'Subnets[].SubnetId' --output text | tr '\t' ' ')"
    aws rds describe-db-subnet-groups --db-subnet-group-name "$SUBNET_GROUP" >/dev/null 2>&1 ||
      aws rds create-db-subnet-group --db-subnet-group-name "$SUBNET_GROUP" \
        --db-subnet-group-description "uilines subnets" \
        --subnet-ids $SUBNETS >/dev/null
    ENGINE_VERSION="$(aws rds describe-db-engine-versions --engine mysql \
      --query "DBEngineVersions[?starts_with(EngineVersion,'8.4')].EngineVersion | sort(@) | [-1:]" \
      --output text)"
    [ -n "$ENGINE_VERSION" ] && [ "$ENGINE_VERSION" != "None" ] || ENGINE_VERSION="8.4.3"
    log "创建 RDS ${RDS_ID}（MySQL $ENGINE_VERSION, $RDS_CLASS, 私有访问）…约 5-8 分钟"
    aws rds create-db-instance \
      --db-instance-identifier "$RDS_ID" \
      --engine mysql --engine-version "$ENGINE_VERSION" \
      --db-instance-class "$RDS_CLASS" \
      --allocated-storage "$RDS_STORAGE" --storage-type gp3 \
      --master-username "$DB_USER" --master-user-password "$DB_PASSWORD" \
      --db-name "$DB_NAME" \
      --vpc-security-group-ids "$DB_SG" \
      --db-subnet-group-name "$SUBNET_GROUP" \
      --backup-retention-period 7 \
      --no-publicly-accessible --no-multi-az >/dev/null
  fi
  aws rds wait db-instance-available --db-instance-identifier "$RDS_ID"
  DB_HOST="$(aws rds describe-db-instances --db-instance-identifier "$RDS_ID" \
    --query 'DBInstances[0].Endpoint.Address' --output text)"
  log "数据库就绪：$DB_HOST"
else
  DB_HOST="mysql" # compose 服务名（同机容器）
  log "使用同机 MySQL 容器（${DB_HOST}）"
fi
DATABASE_URL="mysql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:3306/${DB_NAME}"

log "=========== 步骤 6/11：EC2 实例 ==========="
INSTANCE_ID="$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || true)"
if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
  INSTANCE_ID="$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$WEB_SG" \
    --iam-instance-profile "Name=$IAM_ROLE_NAME" \
    --user-data "file://$SCRIPT_DIR/user-data.sh" \
    --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=30,VolumeType=gp3}' \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query 'Instances[0].InstanceId' --output text)"
  log "已创建实例 ${INSTANCE_ID}（首次启动脚本正在安装 Docker）"
else
  log "复用已有实例 $INSTANCE_ID"
fi
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
state_set INSTANCE_ID "$INSTANCE_ID"
state_set AWS_REGION "$AWS_REGION"
state_set PUBLIC_IP "" # 下一步拿到弹性 IP 后再写入

ALLOC_ID="$(state_get EIP_ALLOC_ID)"
if [ -z "$ALLOC_ID" ]; then
  ALLOC_ID="$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)"
  state_set EIP_ALLOC_ID "$ALLOC_ID"
fi
aws ec2 associate-address --instance-id "$INSTANCE_ID" --allocation-id "$ALLOC_ID" >/dev/null 2>&1 ||
  warn "弹性 IP 关联失败（可能已关联），继续"
PUBLIC_IP="$(aws ec2 describe-addresses --allocation-ids "$ALLOC_ID" \
  --query 'Addresses[0].PublicIp' --output text)"
state_set PUBLIC_IP "$PUBLIC_IP"
log "实例公网 IP：$PUBLIC_IP"

log "=========== 步骤 7/11：构建并推送镜像 ==========="
if [ "$IMAGE_MODE" = "local" ]; then
  aws ecr describe-repositories --repository-names "$ECR_REPO" >/dev/null 2>&1 ||
    aws ecr create-repository --repository-name "$ECR_REPO" \
      --image-scanning-configuration scanOnPush=true >/dev/null
  ECR_URI="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO"
  log "登录 ECR 并构建 linux/${INSTANCE_ARCH} 镜像（本机原生架构，通常 1-3 分钟）…"
  aws ecr get-login-password | docker login --username AWS --password-stdin \
    "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com" >/dev/null
  DOCKER_PLATFORM="linux/${INSTANCE_ARCH}"
  docker build --platform "$DOCKER_PLATFORM" -t "$ECR_URI:$IMAGE_TAG" "$ROOT_DIR" ||
    die "本机构建镜像失败"
  docker push "$ECR_URI:$IMAGE_TAG"
  state_set ECR_URI "$ECR_URI"
  log "镜像已推送：$ECR_URI:$IMAGE_TAG"
else
  log "跳过：镜像改在服务器上构建（需要 ≥2GB 内存 + swap）"
fi

log "=========== 步骤 8/11：Route53 域名解析 ==========="
if [ -n "$DOMAIN" ] && [ "$CREATE_DNS" = "1" ]; then
  ZONE_ID="$(state_get HOSTED_ZONE_ID)"
  if [ -z "$ZONE_ID" ]; then
    ZONE_ID="$(aws route53 list-hosted-zones \
      --query "HostedZones[?Name=='${DOMAIN}.'].Id | [0]" --output text 2>/dev/null || true)"
    [ "$ZONE_ID" = "None" ] && ZONE_ID=""
  fi
  if [ -z "$ZONE_ID" ]; then
    warn "Route53 里没找到 ${DOMAIN} 的托管区，跳过自动解析（请手动把 A 记录指到 ${PUBLIC_IP}）"
  else
    ZONE_ID="${ZONE_ID#/hostedzone/}"
    state_set HOSTED_ZONE_ID "$ZONE_ID"
    for RECORD in "$DOMAIN" "www.$DOMAIN"; do
      aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --change-batch "{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${RECORD}\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"${PUBLIC_IP}\"}]}}]}" >/dev/null
      log "DNS：${RECORD} → ${PUBLIC_IP}"
    done
  fi
elif [ -n "$DOMAIN" ]; then
  warn "已跳过自动解析：请手动把 ${DOMAIN} 的 A 记录指到 $PUBLIC_IP"
fi

log "=========== 步骤 9/11：等待 SSH 与 Docker ==========="
SSH_OPTS="$SSH_OPTS_BASE -i $PEM_FILE"
SSH_TARGET="ec2-user@$PUBLIC_IP"
for i in $(seq 1 40); do
  if ssh $SSH_OPTS "$SSH_TARGET" 'docker info >/dev/null 2>&1 && docker compose version >/dev/null 2>&1' 2>/dev/null; then
    log "SSH 与 Docker 就绪"
    break
  fi
  [ "$i" -eq 40 ] && die "等待 SSH/Docker 超时：用 ssh -i $PEM_FILE ec2-user@$PUBLIC_IP 手动排查（cloud-init 日志：/var/log/cloud-init-output.log）"
  sleep 15
done

log "=========== 步骤 10/11：上传代码 ==========="
ssh $SSH_OPTS "$SSH_TARGET" "mkdir -p $APP_DIR"
tar --exclude='./node_modules' --exclude='./.next' --exclude='./.git' \
  --exclude='./.env' --exclude='./.tmp' --exclude='./deploy/keys' \
  --exclude='./deploy/.deploy-state.env' --exclude='./deploy/deploy.env' \
  -czf - -C "$ROOT_DIR" . |
  ssh $SSH_OPTS "$SSH_TARGET" "tar -xzf - -C $APP_DIR"
log "代码已同步到 $APP_DIR"

log "=========== 步骤 10/11：写入生产环境变量 ==========="
if [ -n "$DOMAIN" ]; then
  APP_URL="https://$DOMAIN"
else
  APP_URL="http://$PUBLIC_IP"
fi
ENV_BODY="$(cat <<EOF
NODE_ENV=production
DATABASE_URL=$DATABASE_URL
BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
BETTER_AUTH_URL=$APP_URL
NEXT_PUBLIC_APP_URL=$APP_URL
CRON_SECRET=$CRON_SECRET
GEOIP_LOOKUP=$GEOIP_LOOKUP
SUPPORT_EMAIL=$SUPPORT_EMAIL
SUPPORT_PHONE=$SUPPORT_PHONE
APP_DOMAIN=$DOMAIN
ACME_EMAIL=$ACME_EMAIL
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
EOF
)"
ssh $SSH_OPTS "$SSH_TARGET" "cat > $APP_DIR/.env && chmod 600 $APP_DIR/.env" <<<"$ENV_BODY"
log "已写入 $APP_DIR/.env（含随机生成的密钥，保存在 deploy/.deploy-state.env）"

log "=========== 步骤 11/11：初始化数据库并启动 ==========="
COMPOSE_FILES="-f $APP_DIR/deploy/docker-compose.prod.yml"
if [ "$DB_MODE" = "local" ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f $APP_DIR/deploy/docker-compose.localdb.yml"
  log "先启动同机 MySQL 容器…"
  ssh $SSH_OPTS "$SSH_TARGET" \
    "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD' docker compose $COMPOSE_FILES up -d mysql"
fi

# 建表 + 基础数据（在 compose 网络里的一次性容器执行，能解析 mysql / 也能连 RDS）
ssh $SSH_OPTS "$SSH_TARGET" \
  "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' DB_HOST='$DB_HOST' \
   SEED_DEMO_DATA='$SEED_DEMO_DATA' SEED_ADMIN_EMAIL='$ADMIN_EMAIL' SEED_ADMIN_PASSWORD='$ADMIN_PASSWORD' \
   docker compose $COMPOSE_FILES -f $APP_DIR/deploy/docker-compose.dbinit.yml --profile init run --rm -T dbinit"

UP_SERVICES=""
if [ -z "$DOMAIN" ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f $APP_DIR/deploy/docker-compose.ip.yml"
  UP_SERVICES="app"
fi

# 镜像来源：local = 从 ECR 拉取（不占用服务器内存）；instance = 在服务器上构建
if [ "$IMAGE_MODE" = "local" ]; then
  ECR_URI="$(state_get ECR_URI)"
  log "服务器从 ECR 拉取镜像 $ECR_URI:$IMAGE_TAG …"
  ssh $SSH_OPTS "$SSH_TARGET" \
    "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ECR_URI%%/*} >/dev/null 2>&1 || true; \
     docker pull $ECR_URI:$IMAGE_TAG && docker tag $ECR_URI:$IMAGE_TAG uilines:latest" ||
    die "服务器拉取镜像失败（检查实例 IAM 角色是否允许 ECR 只读）"
  UP_FLAGS="-d"
else
  UP_FLAGS="-d --build"
fi

ssh $SSH_OPTS "$SSH_TARGET" \
  "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD' docker compose $COMPOSE_FILES up $UP_FLAGS $UP_SERVICES"

log "等待应用健康检查（首次构建镜像通常 3-6 分钟）…"
for i in $(seq 1 40); do
  if ssh $SSH_OPTS "$SSH_TARGET" 'curl -fsS --max-time 5 http://127.0.0.1:3000/api/health >/dev/null 2>&1'; then
    HEALTH_OK=1
    break
  fi
  sleep 15
done

# 公网可达性（域名可能还没解析，失败只提示不报错）
if [ "$HEALTH_OK" = "1" ] && ! curl -fsS --max-time 8 "$APP_URL/api/health" >/dev/null 2>&1; then
  warn "容器健康但 $APP_URL 仍不可达：通常是 DNS 未解析或证书未签发，稍等 1-2 分钟再试"
fi

echo
log "==================== 部署完成 ===================="
cat <<EOF
访问地址   : $APP_URL
健康检查   : $APP_URL/api/health
服务器     : ssh -i $PEM_FILE ec2-user@$PUBLIC_IP
应用目录   : $APP_DIR （.env 里是全部生产变量）
管理员账号 : $ADMIN_EMAIL / $ADMIN_PASSWORD   ← 登录后请立刻改密码
数据库     : $([ "$DB_MODE" = "rds" ] && echo "RDS ${RDS_ID}（${DB_HOST}，私有）" || echo "同机容器 mysql（数据卷 mysql_data）")

常用运维：
  重新部署：代码改完后本地执行  bash deploy/deploy-aws.sh
            $([ "$IMAGE_MODE" = "local" ] && echo "（会重新构建镜像 → 推 ECR → 服务器拉取重启，约 2-3 分钟）" || echo "（会在服务器上重新构建镜像）")
  看日志  ：ssh -i $PEM_FILE ec2-user@$PUBLIC_IP 'cd $APP_DIR && docker compose $COMPOSE_FILES logs -f app'
  触发统计：curl -X POST -H "x-cron-secret: $CRON_SECRET" $APP_URL/api/cron/daily-stats
  会话登录：aws ssm start-session --target $INSTANCE_ID --region $AWS_REGION   （无需 SSH 密钥）
  销毁资源：bash deploy/deploy-aws.sh --destroy
EOF

if [ -z "$DOMAIN" ]; then
  warn "当前是 HTTP + IP 模式（仅测试用）。绑定域名后：把 A 记录指到 ${PUBLIC_IP}，"
  warn "在 deploy.env 填 DOMAIN / ACME_EMAIL 并重新执行本脚本，即可自动启用 HTTPS。"
fi
if [ "${HEALTH_OK:-0}" != "1" ]; then
  warn "健康检查未在 5 分钟内通过：请查看日志（docker compose logs app），首次构建镜像通常需要 3-6 分钟。"
fi
