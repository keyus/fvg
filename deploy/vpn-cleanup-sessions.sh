#!/usr/bin/env bash
#
# vpn-cleanup-sessions.sh — 清理 OpenVPN Access Server 的「鬼会话」
#
# 背景：AS 免费版按「并发连接数」授权（LicUsage 上限 = 2）。
# 手机 + 电脑正好占满 2 条，只要某端在服务器回收旧会话之前重连
# （Mac 睡眠唤醒、手机切网、客户端 token 重连），就会变成第 3 条而被拒：
#   maximum concurrent_connections exceeded (2)
# 客户端已经消失、服务器却还记着的会话，就是这里的「鬼会话」。
#
# 判定依据：
#   sacli LicUsage   → [已用, 上限]（许可证认为占用了几条）
#   sacli VPNStatus  → 各守护进程里真实在线的客户端
#   已用 > 在线  ⇒  有名额被鬼会话占着
#
# 用法：
#   ./vpn-cleanup-sessions.sh                      # 体检（默认，只读，不动任何东西）
#   ./vpn-cleanup-sessions.sh --apply              # 断开在线会话，释放名额（推荐）
#   ./vpn-cleanup-sessions.sh --apply --all        # 连正常在线的会话也断开（客户端会自动重连）
#   ./vpn-cleanup-sessions.sh --apply --restart    # 断不干净时重启 AS（最彻底）
#   ./vpn-cleanup-sessions.sh --watch 60 --apply   # 每 60 秒巡检，发现鬼会话就清
#   ./vpn-cleanup-sessions.sh --export-fixture /tmp/s.json   # 导出快照（离线调试）
#   ./vpn-cleanup-sessions.sh --fixture /tmp/s.json          # 用快照跑逻辑（不碰服务器）
#
# 可用环境变量（均有对应命令行参数）：
#   VPN_SSH_HOST / VPN_SSH_USER / VPN_SSH_KEY / VPN_KNOWN_HOSTS / VPN_STALE_SECONDS
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SSH_HOST="${VPN_SSH_HOST:-47.131.37.185}"
SSH_USER="${VPN_SSH_USER:-ubuntu}"
SSH_KEY="${VPN_SSH_KEY:-$SCRIPT_DIR/keys/uilines-deploy.pem}"
KNOWN_HOSTS="${VPN_KNOWN_HOSTS:-$SCRIPT_DIR/.known_hosts}"
STALE_SECONDS="${VPN_STALE_SECONDS:-180}"
SACLI="/usr/local/openvpn_as/scripts/sacli"

APPLY=0        # 是否真的动手
KICK_ALL=0     # 连正常在线会话一起断
DO_RESTART=0   # 重启 AS 服务
WATCH=0        # 巡检间隔（秒）
FIXTURE=""     # 用本地快照代替线上采集
EXPORT=""      # 把当前快照导出到文件
PRINT_ONLY=0   # 只打印将执行的命令（用快照调试时自动打开）

usage() {
  awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "${BASH_SOURCE[0]}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1 ;;
    --all) KICK_ALL=1 ;;
    --restart) DO_RESTART=1 ;;
    --watch) WATCH="${2:?--watch 需要秒数}"; shift ;;
    --stale) STALE_SECONDS="${2:?--stale 需要秒数}"; shift ;;
    --host) SSH_HOST="${2:?}"; shift ;;
    --user) SSH_USER="${2:?}"; shift ;;
    --key) SSH_KEY="${2:?}"; shift ;;
    --fixture) FIXTURE="${2:?}"; shift; PRINT_ONLY=1 ;;
    --export-fixture) EXPORT="${2:?}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数：$1" >&2; echo; usage; exit 2 ;;
  esac
  shift
done

if [[ -z "$FIXTURE" && ! -f "$SSH_KEY" ]]; then
  echo "找不到 SSH 私钥：${SSH_KEY}（可用 --key 或 VPN_SSH_KEY 指定）" >&2
  exit 1
fi
command -v python3 >/dev/null 2>&1 || { echo "需要本机 python3 解析 sacli 输出" >&2; exit 1; }

ssh_run() {
  ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
    -o "UserKnownHostsFile=$KNOWN_HOSTS" -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "$@"
}

# 采集快照（许可证用量 / 会话 / 汇总 / 服务器时间），用 ===XXX=== 分隔
snapshot() {
  if [[ -n "$FIXTURE" ]]; then
    cat "$FIXTURE"
    return
  fi
  ssh_run "sudo -n $SACLI LicUsage; echo '===VPNSTATUS==='; \
           sudo -n $SACLI VPNStatus; echo '===SUMMARY==='; \
           sudo -n $SACLI VPNSummary; echo '===NOW==='; date +%s"
}

ANALYZE_PY=$(cat <<'PY'
import json, sys, time

stale_seconds = int(sys.argv[1])
kick_all = sys.argv[2] == "1"

raw = sys.stdin.read()
try:
    lic_raw, rest = raw.split("===VPNSTATUS===", 1)
    status_raw, rest = rest.split("===SUMMARY===", 1)
    summary_raw, now_raw = rest.split("===NOW===", 1)
except ValueError:
    print("快照格式不对（缺少分隔标记）", file=sys.stderr)
    sys.exit(2)

def load(txt):
    try:
        return json.loads(txt.strip())
    except Exception:
        return None

lic, status, summary = load(lic_raw), load(status_raw), load(summary_raw)
try:
    now = int(now_raw.strip())
except ValueError:
    now = int(time.time())

lic_used = lic_max = None
if isinstance(lic, list) and len(lic) >= 2:
    lic_used, lic_max = lic[0], lic[1]

clients, stale_routes = [], []
for daemon, data in (status or {}).items():
    if not isinstance(data, dict):
        continue
    header = data.get("client_list_header") or {}
    for row in data.get("client_list") or []:
        def cell(name, default="", row=row, header=header):
            idx = header.get(name)
            return row[idx] if isinstance(idx, int) and idx < len(row) else default
        clients.append({
            "cn": cell("Common Name"),
            "user": cell("Username"),
            "real": cell("Real Address"),
            "virt": cell("Virtual Address"),
            "since_epoch": int(cell("Connected Since (time_t)", 0) or 0),
            "rx": cell("Bytes Received"),
            "tx": cell("Bytes Sent"),
        })
    rheader = data.get("routing_table_header") or {}
    for row in data.get("routing_table") or []:
        def rcell(name, default="", row=row, rheader=rheader):
            idx = rheader.get(name)
            return row[idx] if isinstance(idx, int) and idx < len(row) else default
        last_epoch = int(rcell("Last Ref (time_t)", 0) or 0)
        age = now - last_epoch if last_epoch else None
        if age is None or age >= stale_seconds:
            stale_routes.append({
                "cn": rcell("Common Name"),
                "real": rcell("Real Address"),
                "last_ref": rcell("Last Ref"),
                "age": age,
            })

def human_age(sec):
    if sec is None:
        return "-"
    if sec < 60:
        return f"{int(sec)}s"
    if sec < 3600:
        return f"{int(sec)//60}m{int(sec)%60}s"
    return f"{int(sec)//3600}h{(int(sec)%3600)//60}m"

def human_bytes(v):
    try:
        n = float(v)
    except Exception:
        return "-"
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{int(n)}B" if unit == "B" else f"{n:.1f}{unit}"
        n /= 1024

live = len(clients)
print(f"许可证用量：{lic_used}/{lic_max}" + ("（免费版上限 2 条并发）" if lic_max == 2 else ""))
if isinstance(summary, dict) and "n_clients" in summary:
    print(f"守护进程在线客户端：{summary['n_clients']}")

if clients:
    print("\n真实在线会话：")
    for c in clients:
        dur = human_age(now - c["since_epoch"]) if c["since_epoch"] else "-"
        print(f"  · {c['cn']}  用户={c['user']}  来自 {c['real']}  内网IP {c['virt']}"
              f"  已连接 {dur}  流量 下行{human_bytes(c['rx'])}/上行{human_bytes(c['tx'])}")
else:
    print("\n真实在线会话：无")

if stale_routes:
    print(f"\n路由表滞留条目（≥{human_age(stale_seconds)} 无流量）：")
    for r in stale_routes:
        print(f"  · {r['cn']}  {r['real']}  最后活跃 {r['last_ref']}（{human_age(r['age'])} 前）")

if lic_used is None:
    print("\n警告：读不到 LicUsage，只能报告状态")
    sys.exit(0)

ghosts = lic_used - live
if ghosts > 0:
    print(f"\n[X] 发现鬼会话：许可证记着 {lic_used} 条，实际在线只有 {live} 条，"
          f"{ghosts} 条名额被占住不释放。")
    sys.exit(10)
if kick_all and live:
    print(f"\n[OK] 没有鬼会话。指定了 --all：将断开 {live} 条在线会话（客户端会自动重连）。")
    sys.exit(11)
print(f"\n[OK] 正常：许可证用量 {lic_used}/{lic_max}，与真实在线 {live} 条一致。")
sys.exit(0)
PY
)

# 解析快照并打印体检报告
# 退出码：0 = 没有鬼会话；10 = 有鬼会话；11 = 没有鬼会话但指定了 --all
analyze() {
  python3 -c "$ANALYZE_PY" "$STALE_SECONDS" "$KICK_ALL"
}

# 从快照里取 VPNStatus 段落（离线模式读文件，线上模式读服务器）
snapshot_vpnstatus() {
  if [[ -n "$FIXTURE" ]]; then
    sed -n '/^===VPNSTATUS===$/,/^===SUMMARY===$/p' "$FIXTURE" | sed '1d;$d'
  else
    ssh_run "sudo -n $SACLI VPNStatus" 2>/dev/null || true
  fi
}

# 读取当前在线会话的 CN / 用户名（去重），输出两行：cn:... / user:...
live_identities() {
  snapshot_vpnstatus | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
cns, users = set(), set()
for v in d.values():
    if not isinstance(v, dict):
        continue
    h = v.get("client_list_header") or {}
    for row in v.get("client_list") or []:
        for key, bucket in (("Common Name", cns), ("Username", users)):
            i = h.get(key)
            if isinstance(i, int) and i < len(row) and str(row[i]).strip():
                bucket.add(str(row[i]))
print("cn:" + ",".join(sorted(cns)))
print("user:" + ",".join(sorted(users)))' || true
}

kick_one() {
  local cn="$1"
  [[ -z "$cn" ]] && return 0
  if [[ "$PRINT_ONLY" -eq 1 ]]; then
    echo "    [演练] sacli --cn '$cn' DisconnectClient"
  else
    echo "    -> 断开 $cn"
    ssh_run "sudo -n $SACLI --cn '$cn' DisconnectClient" 2>&1 | sed 's/^/      /' || true
  fi
}

kick_all() {
  local ids cns users u cn
  ids="$(live_identities)"
  cns="$(printf '%s\n' "$ids" | sed -n 's/^cn://p')"
  users="$(printf '%s\n' "$ids" | sed -n 's/^user://p')"
  if [[ -z "$cns" && -z "$users" ]]; then
    echo "    （没有在线会话可断）"
    return 0
  fi
  # 先按用户断（覆盖同一用户的多条会话），再按 CN 兜底
  IFS=',' read -ra user_arr <<< "$users"
  for u in "${user_arr[@]}"; do
    [[ -z "$u" ]] && continue
    if [[ "$PRINT_ONLY" -eq 1 ]]; then
      echo "    [演练] sacli --user '$u' DisconnectUser"
    else
      echo "    -> 断开用户 $u 的全部会话"
      ssh_run "sudo -n $SACLI --user '$u' DisconnectUser" 2>&1 | sed 's/^/      /' || true
    fi
  done
  IFS=',' read -ra cn_arr <<< "$cns"
  for cn in "${cn_arr[@]}"; do
    kick_one "$cn"
  done
}

lic_used_now() {
  if [[ "$PRINT_ONLY" -eq 1 ]]; then
    echo "(演练)"
    return 0
  fi
  ssh_run "sudo -n $SACLI LicUsage" 2>/dev/null |
    python3 -c 'import json,sys;print(json.load(sys.stdin)[0])' 2>/dev/null || echo "?"
}

restart_service() {
  if [[ "$PRINT_ONLY" -eq 1 ]]; then
    echo "    [演练] sudo systemctl restart openvpnas"
    return 0
  fi
  echo "    -> 重启 Access Server（清空全部会话状态）"
  ssh_run "sudo -n systemctl restart openvpnas" || true
  echo "    -> 等待服务就绪..."
  sleep 6
}

cycle() {
  local report rc before after
  set +e
  report="$(snapshot | analyze)"
  rc=$?
  set -e
  printf '%s\n' "$report"

  case "$rc" in
    0)
      if [[ "$APPLY" -eq 1 && "$KICK_ALL" -eq 1 ]]; then
        echo
        echo "按 --all 断开在线会话："
        kick_all
        echo
        echo "清理后："
        snapshot | analyze || true
      fi
      ;;
    11)
      if [[ "$APPLY" -eq 1 ]]; then
        echo
        echo "按 --all 断开在线会话："
        kick_all
        echo
        echo "清理后："
        snapshot | analyze || true
      fi
      ;;
    10)
      if [[ "$APPLY" -eq 0 ]]; then
        echo
        echo "（体检模式，未做任何改动）"
        echo "  清理鬼会话：   $0 --apply"
        echo "  断开全部会话： $0 --apply --all"
        echo "  重启 AS 服务： $0 --apply --restart"
        return 0
      fi
      before="$(lic_used_now)"
      echo
      echo "开始清理（当前许可证占用：${before}）..."
      kick_all
      sleep 3
      after="$(lic_used_now)"
      echo "    许可证占用：$before -> $after"
      if [[ "$after" != "0" ]]; then
        if [[ "$DO_RESTART" -eq 1 ]]; then
          echo "    仍有 $after 条残留，重启服务清空"
          restart_service
        else
          echo "    [!] 仍有 $after 条会话残留（这类鬼会话 sacli 断开无效）"
          echo "        需要重启服务： $0 --apply --restart"
        fi
      fi
      echo
      echo "清理后："
      snapshot | analyze || true
      ;;
    *)
      echo "（无法判断，跳过本轮）" >&2
      ;;
  esac
}

# ---------------------------------- 入口 ----------------------------------

if [[ -n "$EXPORT" ]]; then
  snapshot > "$EXPORT"
  echo "快照已导出：$EXPORT"
  exit 0
fi

if [[ -n "$FIXTURE" ]]; then
  echo "目标：$SSH_USER@${SSH_HOST}（离线快照：${FIXTURE}）"
else
  echo "目标：$SSH_USER@$SSH_HOST"
fi
echo

if [[ "$WATCH" -gt 0 ]]; then
  echo "巡检模式：每 ${WATCH}s 检查一次（Ctrl-C 退出）"
  while true; do
    echo "-------------------------------------------"
    date "+%Y-%m-%d %H:%M:%S"
    cycle || true
    sleep "$WATCH"
  done
else
  cycle
fi
