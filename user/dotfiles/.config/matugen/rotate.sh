#!/usr/bin/env bash
# Cron-friendly wallpaper rotator: 从 Hyprland 会话注入环境后调用 wallpaper.sh
set -euo pipefail

LOG="${HOME}/.cache/matugen/rotate.log"
mkdir -p "$(dirname "$LOG")"

# 从一个正在运行的 Hyprland 进程里拉环境变量
HYPR_PID=$(pgrep -u "$(id -u)" -x Hyprland | head -1 || true)
if [[ -z "${HYPR_PID:-}" ]]; then
    echo "[$(date '+%F %T')] Hyprland not running, skip" >>"$LOG"
    exit 0
fi

# Hyprland 自己 environ 不带 WAYLAND_DISPLAY / HYPRLAND_INSTANCE_SIGNATURE
# (它是这俩变量的生成者)。必须从一个 environ 里真的含 HYPRLAND_INSTANCE_SIGNATURE
# 的子进程拉。扩大候选范围以应对部分 daemon 暂时不在的情况。
ENV_SRC_PID=""
for cand in $(pgrep -u "$(id -u)" -x awww-daemon || true) \
            $(pgrep -u "$(id -u)" -x fcitx5      || true) \
            $(pgrep -u "$(id -u)" -x waybar      || true) \
            $(pgrep -u "$(id -u)" -x swaync      || true) \
            $(pgrep -u "$(id -u)" -x mako        || true) \
            $(pgrep -u "$(id -u)" -x Xwayland    || true) \
            $(pgrep -u "$(id -u)" -x hyprpaper   || true) \
            $(pgrep -u "$(id -u)" -x dunst       || true) \
            $(pgrep -u "$(id -u)" -x kitty       || true); do
    [[ -r "/proc/${cand}/environ" ]] || continue
    if grep -aqz '^HYPRLAND_INSTANCE_SIGNATURE=' "/proc/${cand}/environ" 2>/dev/null; then
        ENV_SRC_PID="$cand"; break
    fi
done

if [[ -z "$ENV_SRC_PID" ]]; then
    echo "[$(date '+%F %T')] no env-bearing child of Hyprland found, skip" >>"$LOG"
    exit 0
fi

while IFS='=' read -r -d '' k v; do
    case "$k" in
        WAYLAND_DISPLAY|XDG_RUNTIME_DIR|HYPRLAND_INSTANCE_SIGNATURE|DISPLAY|DBUS_SESSION_BUS_ADDRESS|XDG_SESSION_TYPE|PATH)
            export "$k=$v"
            ;;
    esac
done < "/proc/${ENV_SRC_PID}/environ"

# 兜底默认
: "${WAYLAND_DISPLAY:=wayland-1}"
: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
export WAYLAND_DISPLAY XDG_RUNTIME_DIR

cd "$HOME"
{
    echo "[$(date '+%F %T')] rotate start"
    "$HOME/.config/matugen/wallpaper.sh"
    echo "[$(date '+%F %T')] rotate done"
} >>"$LOG" 2>&1
