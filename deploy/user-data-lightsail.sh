#!/bin/sh
# Lightsail（Ubuntu 24.04）首次启动脚本：装 Docker + Compose、加 2G swap
# 512MB 内存的 nano 套餐必须靠 swap 兜底，否则 MySQL + Node 会 OOM
# 注意：cloud-init 用 /bin/sh (dash) 执行 user-data，所以这里先切回 bash，
# 否则 `set -o pipefail` 会报 Illegal option 直接中断（实测踩过）。
if [ -z "${BASH_VERSION:-}" ] && [ -x /bin/bash ]; then exec /bin/bash "$0" "$@"; fi
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# ---- swap（先做，后面装包/起容器都受益）----
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap sw 0 0" >>/etc/fstab
  # 让内核更愿意把冷数据换出去（内存小，尽量留 RAM 给 MySQL 缓冲池）
  echo "vm.swappiness=60" >>/etc/sysctl.conf
fi

# ---- Docker ----
apt-get update -y
apt-get install -y docker.io docker-compose-v2 curl tar gzip ca-certificates ||
  apt-get install -y docker.io docker-compose-plugin curl tar gzip ca-certificates
systemctl enable --now docker
usermod -aG docker ubuntu

# compose v2 兜底（部分 Ubuntu 版本没有 docker-compose-v2 包）
if ! docker compose version >/dev/null 2>&1; then
  mkdir -p /usr/libexec/docker/cli-plugins
  ARCH="$(dpkg --print-architecture)"   # amd64 / arm64
  curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64" \
    -o /usr/libexec/docker/cli-plugins/docker-compose
  chmod +x /usr/libexec/docker/cli-plugins/docker-compose
  echo "compose 已按 $ARCH 安装"
fi

mkdir -p /srv/uilines
chown ubuntu:ubuntu /srv/uilines
touch /var/lib/uilines-bootstrap-done
