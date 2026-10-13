#!/bin/bash
# EC2 首次启动脚本（cloud-init user-data）：装 Docker + compose，并准备应用目录
set -euxo pipefail

dnf install -y docker git tar gzip
systemctl enable --now docker
usermod -aG docker ec2-user

# Docker Compose v2 插件（AL2023 的 docker 包不总是自带）
if ! docker compose version >/dev/null 2>&1; then
  mkdir -p /usr/libexec/docker/cli-plugins
  case "$(uname -m)" in
    aarch64 | arm64) COMPOSE_ARCH=aarch64 ;;
    *) COMPOSE_ARCH=x86_64 ;;
  esac
  curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${COMPOSE_ARCH}" \
    -o /usr/libexec/docker/cli-plugins/docker-compose
  chmod +x /usr/libexec/docker/cli-plugins/docker-compose
fi

# 小内存实例（2GB）在构建镜像时容易 OOM，加 2GB swap 兜底
if [ ! -f /swapfile ]; then
  dd if=/dev/zero of=/swapfile bs=1M count=2048
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap sw 0 0" >>/etc/fstab
fi

mkdir -p /srv/uilines
chown ec2-user:ec2-user /srv/uilines
touch /var/lib/uilines-bootstrap-done
