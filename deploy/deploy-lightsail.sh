#!/usr/bin/env bash
#
# uilines 一键部署到 AWS Lightsail（最低配方案：网站 + MySQL + Caddy 全在一台机器上）
#
#   cp deploy/deploy.env.example deploy/deploy.env    # 填参数
#   bash deploy/deploy-lightsail.sh --plan            # 只打印计划，不动 AWS
#   bash deploy/deploy-lightsail.sh                   # 真正部署（约 10 分钟）
#   bash deploy/deploy-lightsail.sh --destroy         # 一键回收（含静态 IP / ECR / DNS 记录）
#
# 设计要点：
# - 镜像在**本机构建**（linux/amd64，Docker Desktop 有 Rosetta 加速，约 2 分钟）后推 ECR，
#   Lightsail 只负责运行，因此 512MB 的 $3.5 套餐也能用（已自动加 2G swap + MySQL 低内存参数）。
# - 数据存在 Lightsail 实例的 20GB SSD 上（MySQL 容器卷）；要做备份见 README。
# - 幂等：重复执行复用已有资源与密钥（状态在 deploy/.deploy-state.env）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/deploy.env}"
STATE_FILE="$SCRIPT_DIR/.deploy-state.env"

MODE="deploy"
for arg in "$@"; do
  case "$arg" in
    --plan) MODE="plan" ;;
    --destroy) MODE="destroy" ;;
    -h | --help)
      sed -n '2,14p' "$0"
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

AWS_REGION="${AWS_REGION:-ap-east-1}"
AWS_PROFILE="${AWS_PROFILE:-}"
LS_NAME="${LS_NAME:-${INSTANCE_NAME:-uilines}}"
LS_BUNDLE="${LS_BUNDLE:-auto}"
LS_BLUEPRINT="${LS_BLUEPRINT:-ubuntu_24_04}"
LS_AZ="${LS_AZ:-}"
KEY_NAME="${KEY_NAME:-${LS_NAME}-deploy}"
SSH_ALLOW_CIDR="${SSH_ALLOW_CIDR:-}"
DOMAIN="${DOMAIN:-}"
ACME_EMAIL="${ACME_EMAIL:-}"
CREATE_DNS="${CREATE_DNS:-1}"
CREATE_WWW="${CREATE_WWW:-1}"
DB_NAME="${DB_NAME:-uilines}"
DB_USER="${DB_USER:-uilines}"
ECR_REPO="${ECR_REPO:-${LS_NAME}}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
SEED_DEMO_DATA="${SEED_DEMO_DATA:-0}"
# auto = 库里已有会员数据就只同步表结构（不重跑 seed，避免删掉后台自建的商品/博客）；
# 1 = 强制跑 seed；0 = 永不跑 seed
SEED_ON_DEPLOY="${SEED_ON_DEPLOY:-auto}"
GEOIP_LOOKUP="${GEOIP_LOOKUP:-0}"
INSTALL_VPN="${INSTALL_VPN:-0}"
SUPPORT_EMAIL="${SUPPORT_EMAIL:-}"
SUPPORT_PHONE="${SUPPORT_PHONE:-}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@uilines.dev}"
APP_DIR="/srv/${LS_NAME}"
STATIC_IP_NAME="${LS_NAME}-ip"
PEM_FILE="$SCRIPT_DIR/keys/${KEY_NAME}.pem"
SSH_USER="ubuntu" # Ubuntu 蓝图默认用户（若换 amazon_linux 蓝图请改成 ec2-user）

if [ -n "$DOMAIN" ] && [ -z "$ACME_EMAIL" ]; then
  die "配置了 DOMAIN 就必须给 ACME_EMAIL（申请 Let's Encrypt 证书用）"
fi
if [ -z "$SSH_ALLOW_CIDR" ]; then
  MY_IP="$(curl -fsS --max-time 8 https://checkip.amazonaws.com 2>/dev/null | tr -d '\n' || true)"
  [ -n "$MY_IP" ] || die "无法获取本机公网 IP，请在 deploy.env 里显式设置 SSH_ALLOW_CIDR"
  SSH_ALLOW_CIDR="$MY_IP/32"
  SSH_CIDR_AUTODETECTED=1
fi
SSH_CIDR_AUTODETECTED="${SSH_CIDR_AUTODETECTED:-0}"

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

DATABASE_URL="mysql://${DB_USER}:${DB_PASSWORD}@mysql:3306/${DB_NAME}"
# 三个文件一起加载：dbinit 带 profiles: ["init"]，平时 up 不会启动它，
# 但 localdb 里的 dbinit.depends_on 需要这个服务定义存在，否则 compose 会报错
COMPOSE_FILES="-f $APP_DIR/deploy/docker-compose.prod.yml -f $APP_DIR/deploy/docker-compose.localdb.yml -f $APP_DIR/deploy/docker-compose.dbinit.yml"

# ---------------------------------------------------------------- 计划模式
if [ "$MODE" = "plan" ]; then
  cat <<EOF
即将执行（--plan 只打印，不调用 AWS）：

  Lightsail 实例   : ${LS_NAME}（套餐 ${LS_BUNDLE}，蓝图 ${LS_BLUEPRINT}，区域 ${AWS_REGION}）
  SSH 来源         : ${SSH_ALLOW_CIDR}（密钥 ${KEY_NAME}，私钥存 deploy/keys/）
  访问地址         : $([ -n "$DOMAIN" ] && echo "https://${DOMAIN}（Caddy 自动证书）" || echo "http://<静态IP>")
  架构说明         : Lightsail 是 x86_64，镜像在本机构建 linux/amd64（Docker Desktop 加速，约 2 分钟）
  应用镜像         : 本机构建 → 推 ECR（${ECR_REPO}）→ 服务器拉取
  数据库           : 同机 MySQL 8.4 容器（低内存参数 + 2G swap），数据随实例的系统盘
  域名解析         : $([ -n "$DOMAIN" ] && [ "$CREATE_DNS" = "1" ] && echo "自动把 ${DOMAIN}$([ "$CREATE_WWW" = "1" ] && echo " / www.${DOMAIN}") 指向 Lightsail 静态 IP" || echo "手动解析")
  种子数据         : $([ "$SEED_DEMO_DATA" = "0" ] && echo "干净库（跳过模拟会员/演示订单）" || echo "包含演示会员与订单")
  管理员账号       : ${ADMIN_EMAIL}（密码部署结束时打印）

将创建/变更：
  - Lightsail 实例 ${LS_NAME} + 静态 IP ${STATIC_IP_NAME}
  - Lightsail 防火墙：22（仅 ${SSH_ALLOW_CIDR}）、80、443
  - SSH 密钥对 ${KEY_NAME}
  - ECR 仓库 ${ECR_REPO}
$([ -n "$DOMAIN" ] && [ "$CREATE_DNS" = "1" ] && printf '  - Route53：%s 与 www.%s 的 A 记录\n' "$DOMAIN" "$DOMAIN")

费用：Lightsail ${LS_BUNDLE}（含公网 IPv4 与静态 IP；仅 IPv6 的套餐无法用 A 记录解析域名）
      + ECR 镜像存储 < \$1/月
EOF
  exit 0
fi

# ---------------------------------------------------------------- 凭据
require_cmd aws "brew install awscli"
require_cmd docker "安装 Docker Desktop"
require_cmd ssh "系统自带"
require_cmd tar "系统自带"
require_cmd openssl "系统自带"
require_cmd base64 "系统自带"

if [ -n "$AWS_PROFILE" ]; then
  aws() { command aws --region "$AWS_REGION" --profile "$AWS_PROFILE" "$@"; }
else
  aws() { command aws --region "$AWS_REGION" "$@"; }
fi

log "校验 AWS 凭据…"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
[ -n "$ACCOUNT_ID" ] && [ "$ACCOUNT_ID" != "None" ] ||
  die "AWS 凭据不可用：先执行 aws login 或 aws configure"
log "账号 ${ACCOUNT_ID} / 区域 ${AWS_REGION}"

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

ls_instance_state() {
  aws lightsail get-instance --instance-name "$LS_NAME" \
    --query 'instance.state.name' --output text 2>/dev/null || echo "missing"
}

# ---------------------------------------------------------------- destroy
if [ "$MODE" = "destroy" ]; then
  warn "将删除：Lightsail 实例 ${LS_NAME}（含实例上的 MySQL 数据）、静态 IP、SSH 密钥、ECR 仓库 ${ECR_REPO}"
  warn "以及 Route53 里本脚本写入的 A 记录（${DOMAIN}）"
  [ "${DESTROY_CONFIRM:-}" = "yes" ] || ask_confirm "确认继续？"

  if [ "$(ls_instance_state)" != "missing" ]; then
    aws lightsail delete-instance --instance-name "$LS_NAME" >/dev/null || warn "实例删除失败，请到控制台确认"
    log "已请求删除实例 ${LS_NAME}（快照未创建，数据不可恢复）"
    sleep 5
  fi
  if aws lightsail get-static-ip --static-ip-name "$STATIC_IP_NAME" >/dev/null 2>&1; then
    aws lightsail detach-static-ip --static-ip-name "$STATIC_IP_NAME" >/dev/null 2>&1 || true
    aws lightsail release-static-ip --static-ip-name "$STATIC_IP_NAME" >/dev/null 2>&1 || true
    log "已释放静态 IP"
  fi
  if aws lightsail get-key-pair --key-pair-name "$KEY_NAME" >/dev/null 2>&1; then
    aws lightsail delete-key-pair --key-pair-name "$KEY_NAME" >/dev/null 2>&1 || true
  fi
  ZONE_ID="$(state_get HOSTED_ZONE_ID)"
  if [ -n "$ZONE_ID" ] && [ -n "$DOMAIN" ]; then
    RECORDS="$DOMAIN"
    [ "$CREATE_WWW" = "1" ] && RECORDS="$RECORDS www.$DOMAIN"
    for RECORD in $RECORDS; do
      aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --change-batch "{\"Changes\":[{\"Action\":\"DELETE\",\"ResourceRecordSet\":{\"Name\":\"${RECORD}\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$(state_get PUBLIC_IP)\"}]}}]}" >/dev/null 2>&1 ||
        warn "DNS 记录 ${RECORD} 删除失败，请手动确认"
    done
  fi
  if aws ecr describe-repositories --repository-names "$ECR_REPO" >/dev/null 2>&1; then
    aws ecr delete-repository --repository-name "$ECR_REPO" --force >/dev/null
    log "已删除 ECR 仓库"
  fi
  log "回收完成"
  exit 0
fi

# ---------------------------------------------------------------- 1. Lightsail 区域开通
log "=========== 步骤 1/11：确认 Lightsail 区域可用 ==========="
waited=0
while true; do
  BUNDLES="$(aws lightsail get-bundles --query 'bundles[].bundleId' --output text 2>&1 || true)"
  case "$BUNDLES" in
    *RegionSetupInProgress*)
      [ "$waited" -eq 0 ] && warn "该账号的 Lightsail（${AWS_REGION}）正在开通：AWS 首次访问要等几分钟"
      waited=$((waited + 1))
      [ "$waited" -ge 30 ] &&
        die "等待超时。请打开一次 Lightsail 控制台（区域选香港）再重跑：https://lightsail.aws.amazon.com/ls/webapp/home/instances"
      sleep 20
      ;;
    *AccessDenied* | *UnauthorizedOperation*)
      die "凭据没有 Lightsail 权限：请给当前身份（或换成 IAM 用户）授予 Lightsail 完全访问权限"
      ;;
    *)
      break
      ;;
  esac
done
echo "$BUNDLES" | tr '\t' '\n' | grep -qx "$LS_BUNDLE" ||
  if [ "$LS_BUNDLE" = "auto" ]; then
    # 自动挑「含公网 IPv4」的最便宜 nano 套餐
    # 注意必须要求 publicIpv4AddressCount>=1：仅 IPv6 的套餐无法挂静态 IP / 无法用 A 记录解析
    LS_BUNDLE="$(aws lightsail get-bundles \
      --query 'bundles[?ramSizeInGb<=`0.5` && publicIpv4AddressCount>=`1` && contains(supportedPlatforms, `LINUX_UNIX`)].bundleId' \
      --output text | tr '\t' '\n' | grep -v ipv6 | sort | tail -1)"
    [ -n "$LS_BUNDLE" ] || die "找不到 nano 套餐，请手动在 deploy.env 指定 LS_BUNDLE"
    log "自动选择套餐：${LS_BUNDLE}"
  else
    die "套餐 ${LS_BUNDLE} 在该区域不存在，可选：$(echo "$BUNDLES" | tr '\t' ' ' | cut -c1-200)"
  fi
log "Lightsail 可用，套餐 ${LS_BUNDLE} 有效"

# ---------------------------------------------------------------- 2. 密钥对
log "=========== 步骤 2/11：SSH 密钥对 ==========="
mkdir -p "$SCRIPT_DIR/keys"
chmod 700 "$SCRIPT_DIR/keys"
if aws lightsail get-key-pair --key-pair-name "$KEY_NAME" >/dev/null 2>&1; then
  [ -f "$PEM_FILE" ] ||
    die "Lightsail 已有密钥 ${KEY_NAME}，但本地缺 ${PEM_FILE}；把私钥放回去，或在 deploy.env 换一个 KEY_NAME"
  log "复用已有密钥 ${KEY_NAME}"
else
  # 注意：Lightsail API 的 privateKeyBase64 经 CLI `--output text` 后已经是明文 PEM，
  # 不要再做一次 base64 解码（否则私钥损坏，SSH 会报 invalid format）。
  aws lightsail create-key-pair --key-pair-name "$KEY_NAME" \
    --query 'privateKeyBase64' --output text >"$PEM_FILE"
  chmod 600 "$PEM_FILE"
  ssh-keygen -y -f "$PEM_FILE" >/dev/null 2>&1 ||
    die "下载的私钥不可用（${PEM_FILE}）：请删除 Lightsail 密钥 ${KEY_NAME} 后重跑脚本"
  log "已创建密钥并保存私钥到 ${PEM_FILE}"
fi

# ---------------------------------------------------------------- 3. 创建实例
log "=========== 步骤 3/11：创建 Lightsail 实例 ==========="
if [ "$(ls_instance_state)" = "missing" ]; then
  if [ -z "$LS_AZ" ]; then
    LS_AZ="$(aws lightsail get-regions --region us-east-1 --include-availability-zones \
      --query "regions[?name=='${AWS_REGION}'].availabilityZones[0].zoneName" --output text 2>/dev/null || true)"
    case "$LS_AZ" in "" | "None") LS_AZ="${AWS_REGION}a" ;; esac
  fi
  aws lightsail create-instances \
    --instance-names "$LS_NAME" \
    --availability-zone "$LS_AZ" \
    --blueprint-id "$LS_BLUEPRINT" \
    --bundle-id "$LS_BUNDLE" \
    --key-pair-name "$KEY_NAME" \
    --user-data "$(cat "$SCRIPT_DIR/user-data-lightsail.sh")" >/dev/null
  log "已创建实例 ${LS_NAME}（${LS_AZ}），正在等待 running 与初始化脚本…"
else
  log "复用已有实例 ${LS_NAME}（状态 $(ls_instance_state)）"
fi

for i in $(seq 1 60); do
  [ "$(ls_instance_state)" = "running" ] && break
  [ "$i" -eq 60 ] && die "实例 20 分钟仍未 running，请到 Lightsail 控制台查看"
  sleep 20
done
state_set LS_NAME "$LS_NAME"

# ---------------------------------------------------------------- 4. 静态 IP + 防火墙
log "=========== 步骤 4/11：静态 IP 与防火墙 ==========="
if ! aws lightsail get-static-ip --static-ip-name "$STATIC_IP_NAME" >/dev/null 2>&1; then
  aws lightsail allocate-static-ip --static-ip-name "$STATIC_IP_NAME" >/dev/null
  log "已分配静态 IP ${STATIC_IP_NAME}"
fi
aws lightsail attach-static-ip --static-ip-name "$STATIC_IP_NAME" --instance-name "$LS_NAME" >/dev/null 2>&1 ||
  warn "静态 IP 关联失败（可能已关联）"
PUBLIC_IP="$(aws lightsail get-static-ip --static-ip-name "$STATIC_IP_NAME" \
  --query 'staticIp.ipAddress' --output text)"
state_set PUBLIC_IP "$PUBLIC_IP"
log "静态 IP：${PUBLIC_IP}"

if [ "$INSTALL_VPN" = "1" ]; then
  # OpenVPN 与网站同机：443 归 Caddy。
  # 1194/udp = VPN 主通道；4443/tcp = VPN 的 TCP 兜底通道（原 443，避让 Caddy）；
  # 943/tcp = AS 管理/客户端 Web UI。
  # 注意：Lightsail 的 put-instance-public-ports 是「整表覆盖」，
  # 这里漏掉的端口会在每次部署时被关掉（曾经漏掉 943/4443 导致管理界面打不开）。
  VPN_PORTS=',{"fromPort":1194,"toPort":1194,"protocol":"udp","cidrs":["0.0.0.0/0"]},{"fromPort":4443,"toPort":4443,"protocol":"tcp","cidrs":["0.0.0.0/0"]},{"fromPort":943,"toPort":943,"protocol":"tcp","cidrs":["0.0.0.0/0"]}'
else
  VPN_PORTS=''
fi

# 自锁保护：如果「本机出口 IP」等于本机公网 IP，说明当前正连着这台服务器的 VPN，
# 此时若把 22 端口规则改成服务器自己的 IP，就会把自己（以及脚本自己）锁在外面。
# 这时保留原有的 22 端口规则不变。
SSH_CIDR="$SSH_ALLOW_CIDR"
if [ "$SSH_CIDR_AUTODETECTED" = "1" ] && [ "$SSH_ALLOW_CIDR" = "${PUBLIC_IP}/32" ]; then
  EXISTING_CIDR="$(aws lightsail get-instance-port-states --instance-name "$LS_NAME" \
    --query 'portStates[?fromPort==`22`].cidrs[]' --output text 2>/dev/null | tr '\t' '\n' | head -1)"
  if [ -n "$EXISTING_CIDR" ]; then
    SSH_CIDR="$EXISTING_CIDR"
    warn "检测到的出口 IP 就是本机（你在连这台服务器的 VPN）——保留原有 22 端口白名单 ${SSH_CIDR}，避免把自己锁在外面"
    warn "（想改 SSH 白名单请在 deploy.env 显式设置 SSH_ALLOW_CIDR）"
  else
    warn "检测到的出口 IP 就是本机，且现有白名单为空：22 端口将保持原样，请手动确认"
  fi
fi

aws lightsail put-instance-public-ports --instance-name "$LS_NAME" --port-infos "$(cat <<JSON
[
  {"fromPort":22,"toPort":22,"protocol":"tcp","cidrs":["${SSH_CIDR}"]},
  {"fromPort":80,"toPort":80,"protocol":"tcp","cidrs":["0.0.0.0/0"]},
  {"fromPort":443,"toPort":443,"protocol":"tcp","cidrs":["0.0.0.0/0"]}${VPN_PORTS}
]
JSON
)" >/dev/null
log "防火墙：22 限 ${SSH_ALLOW_CIDR}，80/443 公开$([ "$INSTALL_VPN" = "1" ] && echo '，1194/udp 给 VPN')"

# ---------------------------------------------------------------- 5. DNS
log "=========== 步骤 5/11：Route53 域名解析 ==========="
if [ -n "$DOMAIN" ] && [ "$CREATE_DNS" = "1" ]; then
  ZONE_ID="$(state_get HOSTED_ZONE_ID)"
  if [ -z "$ZONE_ID" ]; then
    ZONE_ID="$(aws route53 list-hosted-zones \
      --query "HostedZones[?Name=='${DOMAIN}.'].Id | [0]" --output text 2>/dev/null || true)"
    [ "$ZONE_ID" = "None" ] && ZONE_ID=""
  fi
  if [ -z "$ZONE_ID" ]; then
    warn "Route53 没找到 ${DOMAIN} 托管区，请手动把 A 记录指到 ${PUBLIC_IP}"
  else
    ZONE_ID="${ZONE_ID#/hostedzone/}"
    state_set HOSTED_ZONE_ID "$ZONE_ID"
    RECORDS="$DOMAIN"
    [ "$CREATE_WWW" = "1" ] && RECORDS="$RECORDS www.$DOMAIN"
    for RECORD in $RECORDS; do
      aws route53 change-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --change-batch "{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"${RECORD}\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"${PUBLIC_IP}\"}]}}]}" >/dev/null
      log "DNS：${RECORD} → ${PUBLIC_IP}"
    done
  fi
elif [ -n "$DOMAIN" ]; then
  warn "已跳过自动解析：请手动把 ${DOMAIN} 的 A 记录指到 ${PUBLIC_IP}"
fi

# ---------------------------------------------------------------- 6. 等 SSH/Docker
log "=========== 步骤 6/11：等待 SSH 与 Docker ==========="
KNOWN_HOSTS_FILE="$SCRIPT_DIR/.known_hosts"
# 实例重建后 IP 可能复用，旧指纹会导致 StrictHostKeyChecking 失败：先清掉该主机的旧记录
[ -f "$KNOWN_HOSTS_FILE" ] && ssh-keygen -R "$PUBLIC_IP" -f "$KNOWN_HOSTS_FILE" >/dev/null 2>&1 || true
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$KNOWN_HOSTS_FILE -o ConnectTimeout=10 -o LogLevel=ERROR -i $PEM_FILE"
SSH_TARGET="${SSH_USER}@${PUBLIC_IP}"
for i in $(seq 1 60); do
  if ssh $SSH_OPTS "$SSH_TARGET" 'docker info >/dev/null 2>&1 && docker compose version >/dev/null 2>&1' 2>/dev/null; then
    log "SSH 与 Docker 就绪"
    break
  fi
  [ "$i" -eq 60 ] && die "等待超时：ssh -i ${PEM_FILE} ${SSH_TARGET} 手动排查；初始化日志在 /var/log/cloud-init-output.log"
  sleep 15
done
ssh $SSH_OPTS "$SSH_TARGET" 'free -m | sed -n "2p"' 2>/dev/null || true

# ---------------------------------------------------------------- 7. 构建并推送镜像
log "=========== 步骤 7/11：本机构建 linux/amd64 镜像并推送 ECR ==========="
aws ecr describe-repositories --repository-names "$ECR_REPO" >/dev/null 2>&1 ||
  aws ecr create-repository --repository-name "$ECR_REPO" \
    --image-scanning-configuration scanOnPush=true >/dev/null
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_URI="${ECR_REGISTRY}/${ECR_REPO}"
ECR_TOKEN="$(aws ecr get-login-password)"
echo "$ECR_TOKEN" | docker login --username AWS --password-stdin "$ECR_REGISTRY" >/dev/null
docker build --platform linux/amd64 -t "${ECR_URI}:${IMAGE_TAG}" "$ROOT_DIR" ||
  die "本机构建镜像失败"
docker push "${ECR_URI}:${IMAGE_TAG}"
state_set ECR_URI "$ECR_URI"
log "镜像已推送：${ECR_URI}:${IMAGE_TAG}"

# ---------------------------------------------------------------- 8. 同步代码
log "=========== 步骤 8/11：同步部署文件到服务器 ==========="
ssh $SSH_OPTS "$SSH_TARGET" "mkdir -p $APP_DIR"
# COPYFILE_DISABLE=1：避免 macOS 扩展属性（LIBARCHIVE.xattr.*）刷屏
# --no-mac-metadata/--no-xattrs：不带 macOS 扩展属性，否则远端 GNU tar 会刷一堆警告
COPYFILE_DISABLE=1 tar --no-mac-metadata --no-xattrs \
  --exclude='./node_modules' --exclude='./.next' --exclude='./.git' \
  --exclude='./.env' --exclude='./.tmp' --exclude='./deploy/keys' \
  --exclude='./deploy/.deploy-state.env' --exclude='./deploy/deploy.env' \
  -czf - -C "$ROOT_DIR" . |
  ssh $SSH_OPTS "$SSH_TARGET" "tar -xzf - -C $APP_DIR"
log "代码已同步到 ${APP_DIR}"

# ---------------------------------------------------------------- 9. 写入 .env
log "=========== 步骤 9/11：写入生产环境变量 ==========="
APP_URL=$([ -n "$DOMAIN" ] && echo "https://${DOMAIN}" || echo "http://${PUBLIC_IP}")
ENV_BODY="$(cat <<EOF
NODE_ENV=production
DATABASE_URL=${DATABASE_URL}
BETTER_AUTH_SECRET=${BETTER_AUTH_SECRET}
BETTER_AUTH_URL=${APP_URL}
NEXT_PUBLIC_APP_URL=${APP_URL}
# 512MB 小机器：限制 Node 老生代堆，留内存给 MySQL
NODE_OPTIONS=--max-old-space-size=320
CRON_SECRET=${CRON_SECRET}
GEOIP_LOOKUP=${GEOIP_LOOKUP}
SUPPORT_EMAIL=${SUPPORT_EMAIL}
SUPPORT_PHONE=${SUPPORT_PHONE}
APP_DOMAIN=${DOMAIN}
ACME_EMAIL=${ACME_EMAIL}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
EOF
)"
ssh $SSH_OPTS "$SSH_TARGET" "cat > $APP_DIR/.env && chmod 600 $APP_DIR/.env" <<<"$ENV_BODY"
log "已写入 ${APP_DIR}/.env"

# ---------------------------------------------------------------- 10. 数据库初始化
log "=========== 步骤 10/11：起数据库并初始化表/数据 ==========="
ssh $SSH_OPTS "$SSH_TARGET" \
  "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD' docker compose $COMPOSE_FILES up -d mysql"

# 决定是否跑 seed：库里已有会员数据时只同步表结构，避免 seed 清理掉后台自建的商品/博客
DO_SEED="$SEED_ON_DEPLOY"
if [ "$SEED_ON_DEPLOY" = "auto" ]; then
  EXISTING_USERS="$(ssh $SSH_OPTS "$SSH_TARGET" \
    "docker exec -e MYSQL_PWD='$DB_PASSWORD' \$(docker ps -qf name=mysql | head -1) mysql -u'$DB_USER' -N -e 'select count(*) from ${DB_NAME}.user' 2>/dev/null || echo 0" |
    tr -d '[:space:]')"
  case "$EXISTING_USERS" in
    '' | *[!0-9]*) EXISTING_USERS=0 ;;
  esac
  if [ "$EXISTING_USERS" -gt 0 ]; then
    DO_SEED=0
    log "库里已有 ${EXISTING_USERS} 个会员 → 只同步表结构（不重跑 seed，避免删掉自建数据）"
  else
    DO_SEED=1
    log "空库 → 建表并写入基础数据（分类/商品/博客/管理员/角色）"
  fi
fi
ssh $SSH_OPTS "$SSH_TARGET" \
  "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' \
   MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD' DB_HOST='mysql' \
   SEED_DEMO_DATA='$SEED_DEMO_DATA' SEED_ADMIN_EMAIL='$ADMIN_EMAIL' SEED_ADMIN_PASSWORD='$ADMIN_PASSWORD' \
   DBINIT_SEED='$DO_SEED' \
   docker compose $COMPOSE_FILES --profile init run --rm -T dbinit"

# ---------------------------------------------------------------- 11. 启动应用
log "=========== 步骤 11/11：拉取镜像并启动 ==========="
ssh $SSH_OPTS "$SSH_TARGET" \
  "echo '$ECR_TOKEN' | docker login --username AWS --password-stdin '$ECR_REGISTRY' >/dev/null && \
   docker pull '${ECR_URI}:${IMAGE_TAG}' && docker tag '${ECR_URI}:${IMAGE_TAG}' uilines:latest" ||
  die "服务器拉取镜像失败"
ssh $SSH_OPTS "$SSH_TARGET" \
  "cd $APP_DIR && DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' MYSQL_ROOT_PASSWORD='$MYSQL_ROOT_PASSWORD' docker compose $COMPOSE_FILES up -d"

log "等待应用健康检查（小机器首次启动约 1-3 分钟）…"
for i in $(seq 1 40); do
  if ssh $SSH_OPTS "$SSH_TARGET" 'curl -fsS --max-time 5 http://127.0.0.1:3000/api/health >/dev/null 2>&1'; then
    HEALTH_OK=1
    break
  fi
  sleep 15
done

# 在线客服消息保留 30 天：装一条每天 03:10 的 crontab（幂等，重复部署不会重复添加）
log "配置聊天消息清理定时任务（每天 03:10 删除 30 天前的消息）…"
ssh $SSH_OPTS "$SSH_TARGET" "CRON_SECRET='$CRON_SECRET' bash -s" <<'EOS' || warn "crontab 配置失败（不影响网站，可稍后手动添加）"
set -e
LINE="10 3 * * * curl -s -X POST -H 'x-cron-secret: $CRON_SECRET' http://127.0.0.1:3000/api/cron/chat-cleanup >/dev/null 2>&1"
if crontab -l 2>/dev/null | grep -q "chat-cleanup"; then
  echo "  - crontab 已存在，跳过"
else
  ( crontab -l 2>/dev/null; echo "$LINE" ) | crontab -
  echo "  - 已写入 crontab"
fi
EOS
if [ "$HEALTH_OK" = "1" ] && ! curl -fsS --max-time 10 "$APP_URL/api/health" >/dev/null 2>&1; then
  warn "${APP_URL} 暂时不可达：通常是 DNS 未生效或 Caddy 还在申请证书，稍等 1-2 分钟"
fi

echo
log "==================== 部署完成 ===================="
cat <<EOF
访问地址   : ${APP_URL}
健康检查   : ${APP_URL}/api/health
静态 IP    : ${PUBLIC_IP}
登录服务器 : ssh -i ${PEM_FILE} ${SSH_TARGET}
应用目录   : ${APP_DIR}（.env 内含全部生产变量）
管理员账号 : ${ADMIN_EMAIL}$([ "$DO_SEED" = "1" ] && echo " / ${ADMIN_PASSWORD}   ← 本次新建，登录后请立刻改密码" || echo "（沿用库里已有账号，密码未改动）")
数据库     : 同机 MySQL 8.4 容器（数据卷 mysql_data，随实例 20GB SSD）

常用运维：
  重新部署：本地执行  bash deploy/deploy-lightsail.sh
  看日志  ：ssh -i ${PEM_FILE} ${SSH_TARGET} "cd ${APP_DIR} && docker compose ${COMPOSE_FILES} logs -f app"
  触发统计：curl -X POST -H "x-cron-secret: ${CRON_SECRET}" ${APP_URL}/api/cron/daily-stats
  回收资源：bash deploy/deploy-lightsail.sh --destroy

提示：512MB 内存靠 2G swap 撑，首次访问某个页面会稍慢属正常；
      若想更顺畅，把 deploy.env 的 LS_BUNDLE 换成 micro_3_1（1GB，约 \$5/月）重跑即可。
EOF
if [ "${HEALTH_OK:-0}" != "1" ]; then
  warn "健康检查未通过：看日志 docker compose logs app；常见原因是内存不足（可先提高套餐或加大 swap）"
fi
