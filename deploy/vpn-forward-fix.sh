#!/bin/bash
# 修复：Docker 会把 iptables FORWARD 默认策略改成 DROP，
# 导致 OpenVPN 客户端「隧道连上但上不了网」（AS 的规则在 nftables，放行不生效）。
#
# 用法（在服务器上执行一次）：sudo bash vpn-forward-fix.sh
set -euo pipefail

# 1) 让 Docker 不再抢占 FORWARD 策略（Docker 28+ 支持）
mkdir -p /etc/docker
python3 - <<'PY'
import json, os
p = '/etc/docker/daemon.json'
d = {}
if os.path.exists(p):
    try:
        d = json.load(open(p))
    except Exception:
        d = {}
d['ip-forward-no-drop'] = True
json.dump(d, open(p, 'w'), indent=2)
print('已写入', p, ':', d)
PY
systemctl restart docker
sleep 20

# 2) 把 FORWARD 策略恢复为 ACCEPT，并在 DOCKER-USER 里显式放行 VPN 网卡
iptables -P FORWARD ACCEPT
iptables -C DOCKER-USER -i as0t+ -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -i as0t+ -j ACCEPT
iptables -C DOCKER-USER -o as0t+ -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -o as0t+ -j ACCEPT

# 3) 开机自动生效（Docker 与 OpenVPN 都起来之后再执行）
cat >/etc/systemd/system/uilines-vpn-forward.service <<'UNIT'
[Unit]
Description=Keep FORWARD policy ACCEPT so OpenVPN clients can reach the internet (Docker sets it to DROP)
After=docker.service openvpnas.service
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'iptables -P FORWARD ACCEPT; iptables -C DOCKER-USER -i as0t+ -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -i as0t+ -j ACCEPT; iptables -C DOCKER-USER -o as0t+ -j ACCEPT 2>/dev/null || iptables -I DOCKER-USER -o as0t+ -j ACCEPT; exit 0'

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now uilines-vpn-forward.service >/dev/null

echo "== 当前 FORWARD 策略：$(iptables -L FORWARD -n | head -1)"
iptables -L DOCKER-USER -n | head -5
echo "完成：VPN 客户端流量现在可以正常转发出去。"
