#!/usr/bin/env bash
# Matugen 壁纸切换入口
# 用法:
#   wallpaper.sh /path/to/wall.jpg     # 指定壁纸
#   wallpaper.sh                       # 从 ~/Pictures/Wallpapers 随机
#   wallpaper.sh -p                    # 用 fuzzel 选择（图形菜单）

set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/Wallpapers}"
STATE_FILE="$HOME/.cache/matugen/current_wallpaper"
mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p \
  "$HOME/.cache/matugen" \
  "$HOME/.cache/wal" \
  "$HOME/.config/btop/themes" \
  "$HOME/.config/swaync" \
  "$HOME/.config/wired" \
  "$HOME/.config/yazi"

ensure_awww() {
  if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    # 等待 socket 就绪
    for _ in {1..20}; do
      awww query >/dev/null 2>&1 && return 0
      sleep 0.1
    done
  fi
}

pick_random() {
  local shuffle_file="$HOME/.cache/matugen/wallpaper_shuffle"

  # Re-shuffle when the queue is empty or doesn't exist
  if [[ ! -s "$shuffle_file" ]]; then
    find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) |
      shuf >"$shuffle_file"
  fi

  # Pop the first entry
  local wall
  wall=$(sed -n '1p' "$shuffle_file")
  sed -i '1d' "$shuffle_file"

  # Clean up empty file so next call re-shuffles
  [[ -s "$shuffle_file" ]] || rm -f "$shuffle_file"

  echo "$wall"
}

pick_fuzzel() {
  find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) |
    fuzzel --dmenu --prompt 'Wallpaper> '
}

case "${1:-}" in
-p | --pick) WALL=$(pick_fuzzel) ;;
"") WALL=$(pick_random) ;;
*) WALL=$1 ;;
esac

[[ -f "$WALL" ]] || {
  echo "Wallpaper not found: $WALL" >&2
  exit 1
}

ensure_awww

# matugen 会通过 [config.wallpaper] 自动调用 awww 来设置壁纸，
# 这里不再重复调用，避免双重过渡动画。

# 生成所有模板 + 跑 post_hook（dark + vibrant）
matugen image "$WALL" --mode dark --type scheme-tonal-spot --contrast 0 --source-color-index 0

echo "$WALL" >"$STATE_FILE"
echo "✓ Wallpaper: $WALL"
