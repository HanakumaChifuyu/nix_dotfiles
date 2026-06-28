#!/usr/bin/env bash

# PID 文件路径
PID_FILE="/tmp/wf-recorder.pid"

# 检查是否已经在录制
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" >/dev/null 2>&1; then
        # 已经在录制，发送 SIGINT 停止
        notify-send "停止录制 (PID: $PID)..."
        kill -SIGINT "$PID"
        rm "$PID_FILE"
        notify-send "录屏" "录制已停止" -t 2000
        exit 0
    else
        # PID 文件存在但进程不存在，清理
        rm "$PID_FILE"
    fi
fi

# 检查必要的工具是否安装
for cmd in slurp wf-recorder wofi hyprctl jq; do
    if ! command -v $cmd &>/dev/null; then
        notify-send "错误" "未找到 $cmd，请先安装" -u critical
        exit 1
    fi
done

# 设置输出文件名（带时间戳）
OUTPUT_DIR="$HOME/Videos/screenrecord/"
mkdir -p "$OUTPUT_DIR"
FILENAME="$OUTPUT_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"

# 使用 wofi 选择录制模式
MODE=$(echo -e "截屏\n区域录制\n全屏录制\n窗口录制" | rofi -dmenu -p "选择录制模式" -theme ~/.config/rofi/themes/select-menu.rasi)

# 检查是否选择了模式
if [ -z "$MODE" ]; then
    exit 1
fi

case "$MODE" in
"截屏")
    /home/tohno/.config/hypr/scripts/Screenshot.sh
    exit
    ;;
"区域录制")
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then
        notify-send "录屏" "未选择区域" -t 2000
        exit 1
    fi
    ;;

"全屏录制")
    GEOMETRY=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.x),\(.y) \(.width)x\(.height)"')
    if [ -z "$GEOMETRY" ]; then
        notify-send "错误" "无法获取显示器信息" -u critical
        exit 1
    fi
    ;;

"窗口录制")
    WINDOWS=$(hyprctl clients -j | jq -r '.[] | "[\(.class)] \(.title)"')

    if [ -z "$WINDOWS" ]; then
        notify-send "错误" "未找到任何窗口" -u critical
        exit 1
    fi

    SELECTED=$(echo "$WINDOWS" | rofi -dmenu -i - "选择要录制的窗口" -theme ~/.config/rofi/themes/select-menu.rasi)

    if [ -z "$SELECTED" ]; then
        exit 1
    fi

    WINDOW_ADDR=$(echo "$SELECTED" | cut -d: -f1)
    WINDOW_INFO=$(hyprctl clients -j | jq -r ".[] | select(.address == \"$WINDOW_ADDR\") | \"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])\"")

    if [ -z "$WINDOW_INFO" ]; then
        notify-send "错误" "无法获取窗口几何信息" -u critical
        exit 1
    fi

    GEOMETRY="$WINDOW_INFO"
    ;;

*)
    exit 1
    ;;
esac

# 开始录制（后台运行）
wf-recorder -g "$GEOMETRY" -f "$FILENAME" &
RECORDER_PID=$!

# 保存 PID
echo $RECORDER_PID >"$PID_FILE"

# 发送通知
notify-send "录屏" "录制已开始\n再次按快捷键停止" -t 3000

# 等待录制进程结束
wait $RECORDER_PID

# 清理 PID 文件
rm -f "$PID_FILE"

# 发送完成通知
notify-send "$FILENAME" "文件已保存:\n$(basename $FILENAME)" -t 3000
