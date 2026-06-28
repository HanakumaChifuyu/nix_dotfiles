#! /usr/bin/env bash
set -e
# --- config ---
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots/"
BORDER=2   # slurp 边框宽度（像素）

if [ ! -d "$SCREENSHOTS_DIR" ]; then
    mkdir -p "$SCREENSHOTS_DIR"
fi

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
FILENAME="screenshot_${TIMESTAMP}.png"
FULLPATH="${SCREENSHOTS_DIR}${FILENAME}"

# 醒目配色：屏幕背景半透明黑、选区透明、边框纯红
REGION=$(slurp -w $BORDER -b 00000080 -c ff0000ff -s 00000000 -B 00000080)

# 解析 slurp 输出 "X,Y WxH"，按边框宽度向内裁剪
read X Y W H <<< "$(echo "$REGION" | awk -F'[ ,x]' '{print $1, $2, $3, $4}')"
NEW_X=$((X + BORDER))
NEW_Y=$((Y + BORDER))
NEW_W=$((W - 2 * BORDER))
NEW_H=$((H - 2 * BORDER))

# 等一帧让 slurp overlay 彻底从合成器中消失，避免边框残留
sleep 0.05

grim -g "${NEW_X},${NEW_Y} ${NEW_W}x${NEW_H}" "$FULLPATH"
wl-copy < "$FULLPATH"

# 通知 + 两个 action 按钮，等待用户点击并 dispatch
ACTION=$(notify-send --wait \
    --icon="$FULLPATH" \
    --app-name="Screenshot" \
    -A "annotate=🖊 标注" \
    -A "copy=📋 复制" \
    "截图已保存" "$FULLPATH")

case "$ACTION" in
    annotate) satty -f "$FULLPATH" ;;
    copy)     wl-copy < "$FULLPATH" ;;
esac
