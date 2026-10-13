# 部署到 AWS（deploy/）

## 当前线上状态（2026-09-19 部署）

| 项目 | 值 |
| --- | --- |
| 地址 | **https://test.uilines.com**（二级域名；主域名 `uilines.com` 与 www 暂不解析，Let's Encrypt 证书自动续期） |
| 服务器 | Lightsail `small_3_0`（2 vCPU / 2GB / 60GB，新加坡 `ap-southeast-1`），静态 IP `47.131.37.185` |
| 组成 | Docker：MySQL 8.4 + Next.js 商城 + Caddy（+ 预留 1194/udp 给 OpenVPN） |
| 后台 | https://test.uilines.com/admin/login （账号密码见 `deploy/.deploy-state.env`，请尽快改密码 + 开 2FA） |
| 健康检查 | https://test.uilines.com/api/health → `{"ok":true,"db":"up"}` |
| 每月费用 | Lightsail $12 + ECR/流量零星 < $1 |

本次部署时的两个坑（脚本已修好，供以后参考）：

1. `aws lightsail create-key-pair --output text` 直接返回明文 PEM，**不要再 base64 解码**，否则私钥损坏（脚本现已加 `ssh-keygen -y` 校验）。
2. cloud-init 用 `/bin/sh` 执行 user-data，`set -o pipefail` 会直接报错中断 → 脚本开头用 `exec /bin/bash` 切回 bash。
3. 数据库初始化容器里**不能写 `sh -c "$VAR"`**：变量展开不会重新解析 `&&` 等运算符，
   会把 `&&` 当成参数传给 bun。现在脚本正文直接写在 compose 的 `command` 里，用 `DBINIT_SEED` 开关控制。

### 重复部署时的数据库策略（重要）

`seed` 脚本会**清理不在种子清单里的商品 / 分类 / 博客**（它假定自己是演示数据的唯一来源），
所以正式库不能无脑重跑。部署脚本现在会自动判断：

| 情况 | 行为 |
| --- | --- |
| 库里已有会员数据（`user` 表非空） | **只同步表结构**（`drizzle-kit push`），跳过 seed，**不会动你的数据** |
| 空库（首次部署） | 建表 + 写入基础数据（分类/商品/博客/管理员/角色） |
| 想强制重跑 seed | `SEED_ON_DEPLOY=1 bash deploy/deploy-lightsail.sh`（注意会清理自建商品/博客） |

当前采用的方案：**Lightsail 最低配 + Docker 全在一台机器上**（网站 + MySQL + Caddy HTTPS）。

### 选套餐：一定要选「含公网 IPv4」的那种

Lightsail 同规格有两类套餐，差别只有**有没有公网 IPv4 地址**（CPU/内存/磁盘/流量完全一样）：

| 套餐 ID | 内存 | 磁盘 | 月费 | 公网 IPv4 | 能否用 `uilines.com` 的 A 记录 |
| --- | --- | --- | --- | --- | --- |
| `nano_ipv6_3_0` | 0.5G | 20G | $3.5 | ❌ 无 | 只能加 AAAA 记录（IPv4-only 网络访问不了） |
| `nano_3_0` | 0.5G | 20G | $5 | ✅ 1 个 | ✅ |
| `micro_ipv6_3_0` | 1.0G | 40G | $5 | ❌ 无 | 同上 |
| `micro_3_0` | 1.0G | 40G | $7 | ✅ 1 个 | ✅（推荐） |
| `small_3_0` | 2.0G | 60G | $12 | ✅ 1 个 | ✅ |

原因：Lightsail 的**静态 IP 产品只有 IPv4**，而且 IPv6 地址在实例停止/重建后可能变化；
只有 A 记录（IPv4）才能保证任何网络（含 IPv4-only 的办公 WiFi、老手机）都能打开网站。
想省钱又用 IPv6-only，就必须再套一层 CloudFront（CloudFront 前端支持 IPv4），反而更贵更复杂。

本项目 `deploy.env` 默认 `LS_BUNDLE=micro_3_0`（$7，1G 内存跑 Next + MySQL 舒服）；
想压到最低就改成 `nano_3_0`（$5，靠 2G swap 撑，能用但偏慢）。

## 一键命令

```bash
cp deploy/deploy.env.example deploy/deploy.env    # 参数（已经按新加坡区 + test.uilines.com 配好一份）
bash deploy/deploy-lightsail.sh --plan            # 只打印计划，不碰 AWS ✅ 已验证
bash deploy/deploy-lightsail.sh                   # 真正部署（约 10 分钟）
bash deploy/deploy-lightsail.sh --destroy         # 一键回收（实例/静态IP/密钥/ECR/DNS 记录）
```

同样的命令也写进了 `package.json`，可以直接用 bun 调用（推荐日常用这几个）：

```bash
bun run deploy            # 一键发布：本机构建镜像 → 推 ECR → 服务器拉取重启（约 3-4 分钟）
bun run deploy:plan       # 只打印部署计划，不调用 AWS
bun run deploy:destroy    # 回收全部云资源（会先要一次确认）
bun run deploy:health     # 查看线上健康检查
bun run deploy:logs       # 实时查看 app + caddy 日志（SSH）
bun run deploy:ssh        # 直接登录服务器
bun run deploy:ec2        # 备用方案：EC2 + RDS 路线（deploy-aws.sh）
bun run deploy:ec2:plan   # 同上，只看计划
```

> 发布前需要：本机 Docker 已启动 + AWS 凭据有效（`aws login`），否则脚本会提示。

> 另有一份 `deploy-aws.sh`：EC2 + RDS + ALB 路线的完整脚本（本机当前用不上，保留备用）。

## 为什么这样设计（512MB 小机器的三个关键点）

1. **镜像在你 Mac 上构建，服务器只运行**。Lightsail 是 x86_64、你的 Mac 是 arm64，
   本机用 `docker build --platform linux/amd64` 构建（Docker Desktop 有 Rosetta 加速，实测 **2 分钟**），
   推到 ECR 后服务器只做 `docker pull`，这样 512MB 内存也不需要在服务器上跑 Next 构建。
2. **2GB swap + MySQL 低内存参数**：`--performance-schema=OFF`、`innodb-buffer-pool-size=96M`、
   `--disable-log-bin`、`max-connections=30`，配合 `NODE_OPTIONS=--max-old-space-size=320`，
   让 MySQL + Node + Caddy 在 512MB 物理内存里能稳住（慢一点，但演示够用）。
3. **数据在实例的 20GB SSD 上**（MySQL 容器卷 `mysql_data`）。想更稳可以把 `LS_BUNDLE`
   换成 `micro_3_1`（1GB，≈$5/月）重跑脚本即可；再往上就该考虑数据库迁到 RDS 了。

## 脚本会创建什么

| 资源 | 说明 |
| --- | --- |
| Lightsail 实例 `uilines` | 套餐 `auto`（自动挑最便宜的 nano ≈$3.5/月），Ubuntu 24.04 |
| 静态 IP `uilines-ip` | 固定公网 IP，DNS 指它（挂机免费） |
| 防火墙 | 22 仅你的出口 IP、80/443 公开 |
| SSH 密钥 `uilines-deploy` | 私钥存 `deploy/keys/`（已 gitignore） |
| ECR 仓库 `uilines` | 存放本机构建好的 amd64 镜像 |
| Route53 | `$DOMAIN` 的 A 记录 → 静态 IP（`CREATE_WWW=1` 时一并解析 `www.$DOMAIN`） |
| 服务器上 | `/srv/uilines`：代码 + `.env` + MySQL 容器 + app + Caddy（自动 HTTPS） |

## 需要你提供什么

| 项目 | 状态 |
| --- | --- |
| AWS 凭据（`aws login` / `aws configure`） | ✅ 已登录（root 账号，建议后续换 IAM 用户） |
| 区域 | ✅ `ap-east-1`（香港）——Lightsail 在本账号首次使用需开通，见下 |
| 域名 | ✅ `test.uilines.com`（二级域名；Route53 托管区 `Z01065033DF9Q7GWXA9MZ`，主域名暂不解析） |
| 证书邮箱 | ⚠️ 默认 `admin@uilines.com`，可改 `ACME_EMAIL` |
| 后台管理员 | ✅ `admin@uilines.dev`，密码脚本随机生成并打印 |
| 是否带演示数据 | ✅ 默认干净库（`SEED_DEMO_DATA=0`） |

> **Lightsail 香港区首次开通**：如果脚本报 `RegionSetupInProgressException`，
> 打开一次 Lightsail 控制台（区域切到香港）后等几分钟再跑即可：
> https://lightsail.aws.amazon.com/ls/webapp/home/instances

## 部署后常用命令

## VPN 迁移（OpenVPN Access Server 3.1.0 → 同一台 Lightsail，2026-09-19）

新服务器上同时跑网站与 VPN，端口分配：

| 用途 | 端口 | 说明 |
| --- | --- | --- |
| 网站 HTTPS | 80 / 443（Caddy） | 443 归网站，所以 VPN 的 TCP 兜底通道挪到 4443 |
| VPN（主通道） | **1194/udp** | 客户端首选 |
| VPN（TCP 兜底） | **4443/tcp** | 原来在 443，因与 Caddy 冲突已改 |
| AS 管理/客户端 Web UI | 943/tcp | `https://v.uilines.com:943/`（自签证书，见下方「Server Address 改成域名」） |

### Server Address 改成域名（2026-09-26）

VPN 的「Server Address」用域名而不是 IP，客户端配置更稳（换 IP 不用重发配置）。已做的三步：

```bash
# 1) Route53 加一条 A 记录（v.uilines.com → 静态 IP；部署脚本不管这条，重跑部署不会删）
aws route53 change-resource-record-sets --hosted-zone-id <ZONE_ID> --change-batch \
  '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"v.uilines.com","Type":"A","TTL":300,"ResourceRecords":[{"Value":"47.131.37.185"}]}}]}'

# 2) AS 里的 Server Address（host.name）写成域名
ssh -i deploy/keys/uilines-deploy.pem ubuntu@47.131.37.185 \
  'sudo /usr/local/openvpn_as/scripts/sacli --key host.name --value v.uilines.com ConfigPut'

# 3) 应用（客户端会短暂掉线并自动重连；会顺带按新域名重生 web 证书）
ssh -i deploy/keys/uilines-deploy.pem ubuntu@47.131.37.185 \
  'sudo /usr/local/openvpn_as/scripts/sacli start'
```

改完之后：

| 项 | 值 |
| --- | --- |
| 客户端 `remote` | `v.uilines.com 1194 udp`（主）/ `v.uilines.com 4443 tcp`（兜底） |
| Web UI | `https://v.uilines.com:943/`（证书 CN 自动变成 `v.uilines.com`，仍是 AS 自签 CA → 浏览器会提示不受信任） |
| 端口 / 防火墙 | 不用动（1194/udp、4443/tcp、943/tcp 早已放行） |
| 老客户端配置 | 继续可用（IP 没变）；想用域名就重新下载一次配置 |

想回滚：把 `host.name` 改回 `47.131.37.185` 再 `sacli start` 即可。

> 若要让 943 用**受信任**证书（浏览器不再报警）：AS 自带的 Let's Encrypt 需要 80 端口做 HTTP-01 校验，
> 而 80 归网站的 Caddy，所以要用「Caddy 先签 `v.uilines.com` → 再把 fullchain/key 导入
> `/usr/local/openvpn_as/etc/web-ssl/`」的方式做，见后续需要时再补。

迁移做法（保留原用户与证书，客户端只需改 IP，不用重新签发证书）：

```bash
# 1) 旧机器打包配置（etc/exe 是 379MB 的二进制，不用迁）
ssh -i ~/my.pem openvpnas@<旧IP> \
  'sudo tar czf /tmp/as-migrate.tar.gz -C /usr/local/openvpn_as/etc db config.json config-local.json as.conf as_templ.conf VERSION web-ssl licenses'
# 2) 新机器：装同源 AS（Ubuntu24 包），停服务 → 覆盖 db/web-ssl → 改端口 → 起服务
sudo apt-get install -y openvpn-as          # 官方源：packages.openvpn.net/as/debian noble main
sudo systemctl stop openvpnas
sudo cp -a /tmp/as-import/db/. /usr/local/openvpn_as/etc/db/
sudo cp -a /tmp/as-import/web-ssl/. /usr/local/openvpn_as/etc/web-ssl/
sudo /usr/local/openvpn_as/scripts/sacli --key vpn.server.daemon.tcp.port --value 4443 ConfigPut
sudo /usr/local/openvpn_as/scripts/sacli --key host.name --value <新IP> ConfigPut
sudo systemctl start openvpnas
```

客户端配置只需把 `remote` 换成新 IP（`1194 udp` 保持，`443 tcp` 改 `4443 tcp`），
其余证书块不用动 —— 已核对：服务端证书库里的 CA 与客户端 profile 中的 `<ca>`/`<cert>` 指纹一致。

### 踩坑记录：VPN 能连上但上不了网（Docker 与 OpenVPN 抢 FORWARD 策略）

装了 Docker 之后，Docker 会把 iptables 的 **FORWARD 默认策略改成 DROP**（防容器转发），
而 OpenVPN AS 3.x 的放行/NAT 规则写在 **nftables**（`as_filter` / `as_nat` 表）里，
两边不在同一条链上，结果是：**客户端隧道建立成功、却无法访问外网**。

一条命令修复（已随脚本提供 `deploy/vpn-forward-fix.sh`，且已做成开机自启）：

```bash
sudo bash deploy/vpn-forward-fix.sh
# 它做三件事：
# 1) /etc/docker/daemon.json 写入 {"ip-forward-no-drop": true}，让 Docker 不再抢占策略
# 2) iptables -P FORWARD ACCEPT，并在 DOCKER-USER 链放行 as0t+ 网卡（进出双向）
# 3) 建立 uilines-vpn-forward.service（After=docker.service openvpnas.service）保证重启后依然生效
```

验证：`iptables -L FORWARD -n | head -1` 应显示 `policy ACCEPT`；
客户端连上后 `nft list chain ip as_filter AS_IN` 的计数应从 0 开始增长。

### 鬼会话清理（`deploy/vpn-cleanup-sessions.sh`）

AS 免费版按**并发连接数**授权（本机 `sacli LicUsage` 返回上限 2）。手机 + 电脑正好占满，
只要某端在服务器回收旧会话之前重连（Mac 睡眠唤醒、手机切网、客户端 token 重连），
就会变成第 3 条而被拒，客户端表现为「握手成功但一直连不上」：

```
MULTI: connection rejected: AS auth failed, CLI:TEMP[backoff 60]:
LICENSE: Access Server license failure: maximum concurrent_connections exceeded (2)
```

这类「客户端已经没了、服务器还记着」的会话就是鬼会话。判定依据：
`sacli LicUsage` 的已用数 **>** `sacli VPNStatus` 里真实在线的客户端数。

```bash
bash deploy/vpn-cleanup-sessions.sh                      # 体检（默认只读，不动任何东西）
bash deploy/vpn-cleanup-sessions.sh --apply              # 断开在线会话，释放名额
bash deploy/vpn-cleanup-sessions.sh --apply --all        # 连正常在线的会话也断开（客户端会自动重连）
bash deploy/vpn-cleanup-sessions.sh --apply --restart    # 断不干净时重启 AS（最彻底）
bash deploy/vpn-cleanup-sessions.sh --watch 60 --apply   # 常驻巡检，发现鬼会话就清

# 离线调试：导出一次快照，之后可以用快照反复跑逻辑（不会碰服务器）
bash deploy/vpn-cleanup-sessions.sh --export-fixture /tmp/vpn-snapshot.json
bash deploy/vpn-cleanup-sessions.sh --fixture /tmp/vpn-snapshot.json --apply --all
```

说明：

- 脚本从本机通过 SSH 跑 `sacli`，需要 Lightsail 防火墙放行本机公网 IP 的 22 端口
  （建议直接放行 ISP 网段，例如 `183.223.133.0/24`，避免家宽动态 IP 频繁改动）。
- `sacli` 断开对「真在线」的会话有效；如果 `LicUsage` 仍不为 0，说明是服务器侧残留计数，
  这时用 `--apply --restart`（等价于 `sudo systemctl restart openvpnas`，客户端会自动重连）。
- 想彻底不受 2 条并发限制，只能买 AS 授权扩容（或改用社区版 OpenVPN 自建）。

```bash
# 重新部署（改完代码就跑这条：本机构建 → 推 ECR → 服务器拉取重启）
bash deploy/deploy-lightsail.sh

# 看日志
ssh -i deploy/keys/uilines-deploy.pem ubuntu@<静态IP> \
  'cd /srv/uilines && docker compose -f deploy/docker-compose.prod.yml -f deploy/docker-compose.localdb.yml logs -f app'

# 触发每日统计
curl -X POST -H "x-cron-secret: <CRON_SECRET>" https://test.uilines.com/api/cron/daily-stats

# 回收全部资源
bash deploy/deploy-lightsail.sh --destroy
```

## 数据库备份 / 恢复（同机 MySQL）

```bash
# 备份到本地
ssh -i deploy/keys/uilines-deploy.pem ubuntu@<IP> \
  'docker exec uilines-mysql sh -c "mysqldump -uroot -p\"$MYSQL_ROOT_PASSWORD\" uilines"' \
  > uilines-$(date +%F).sql

# 恢复
cat uilines-2026-09-19.sql | ssh -i deploy/keys/uilines-deploy.pem ubuntu@<IP> \
  'docker exec -i uilines-mysql sh -c "mysql -uroot -p\"$MYSQL_ROOT_PASSWORD\" uilines"'
```

（Lightsail 也支持实例快照：控制台 → 实例 → Snapshots，建议上线后再打一个。）

## 把本地库（含测试数据）同步到线上

`bun run deploy` **只同步表结构**（`drizzle-kit push`），不会覆盖线上数据。
要把本地整库（新表 + 测试数据）原样同步上去，按下面三步走 —— 会**覆盖线上库**，务必先备份：

```bash
SSH="ssh -i deploy/keys/uilines-deploy.pem -o UserKnownHostsFile=deploy/.known_hosts ubuntu@47.131.37.185"
ROOT_PW="$(grep '^MYSQL_ROOT_PASSWORD=' deploy/.deploy-state.env | cut -d= -f2-)"
MY="deploy-mysql-1"   # 服务器上的 MySQL 容器名，可用 docker ps 确认

# 1) 先备份线上库到本地（一定要做，出问题靠它回滚）
$SSH "docker exec -e MYSQL_PWD='$ROOT_PW' $MY sh -c \
  'exec mysqldump -uroot --single-transaction --no-tablespaces uilines'" \
  > deploy/backups/remote-$(date +%F-%H%M).sql

# 2) 导出本地库（排除 session：本地会话换到线上必然失效，留着没用）
docker exec uilines-mysql sh -c \
  'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --no-tablespaces \
   --routines --events --set-gtid-purged=OFF --ignore-table=uilines.session uilines' \
  > deploy/backups/local-$(date +%F-%H%M).sql

# 3) 导入线上（会 DROP + 重建各表，期间站点短暂报错属正常）
$SSH "docker exec -i -e MYSQL_PWD='$ROOT_PW' $MY mysql -uroot uilines" \
  < deploy/backups/local-<上一步的文件名>.sql
```

导入后核对行数（本地 / 线上应完全一致）：

```bash
docker exec -i uilines-mysql mysql -uroot -proot_secret -N uilines -e \
  "SELECT COUNT(*) FROM products; SELECT COUNT(*) FROM user; SELECT COUNT(*) FROM site_settings;"
```

备注：`session` 表不同步 → 线上已登录的浏览器会话保持有效，本地会话不会带到线上。

## 安全提醒

1. 现在用的是**账号 root 凭据**：部署完建议建一个专用 IAM 用户（或启用 SSO），root 只留 MFA + 账单用途并删掉 Access Key。
2. `deploy/.deploy-state.env` 保存着数据库密码、`BETTER_AUTH_SECRET`、后台管理员密码 —— 已在 `.gitignore` 里，别提交。
3. 上线后立刻登录 `/admin` 改掉默认管理员密码，并开启两步验证（设置 → 安全）。
4. 与项目无关但顺带提醒：你那台 OpenVPN 实例的安全组 `default` 把 0-65535 全开到 `0.0.0.0/0`，建议收紧。
