#!/usr/bin/env bash
# scratchpad-picker.sh — 从后台缓冲区提取窗口
# 依赖: jq, fuzzel

tmp=$(mktemp)

# 用 jq 筛选 special:minimized 里的窗口，并输出 fuzzel 支持的格式（\0icon=...）
hyprctl clients -j | jq -r '.[] | select(.workspace.name == "special:minimized") | "\(.title)  [\(.class)]  (\(.address))\u0000icon=\(.class)"' > "$tmp"

if [ ! -s "$tmp" ]; then
    notify-send "Buffer" "缓冲区目前没有窗口"
    rm -f "$tmp"
    exit 0
fi

# 显示选择菜单
selected=$(fuzzel --dmenu --lines=10 --width=50 --prompt="󰍹  Buffer › " < "$tmp")
rm -f "$tmp"

[[ -z "$selected" ]] && exit 0

# 提取结尾的地址，例如 (0x64fcbc4352a0) -> 0x64fcbc4352a0
addr=$(echo "$selected" | grep -oP '\(0x[0-9a-f]+\)$' | tr -d '()')

if [ -n "$addr" ]; then
    # 获取当前活动工作区 ID
    ws=$(hyprctl activeworkspace -j | jq -r '.id')
    
    # 移动窗口到当前工作区并聚焦（由于启用了 hypr_lua，这里需要传入兼容的 Lua 调用格式）
    hyprctl dispatch "hl.dsp.window.move({workspace=${ws}, window='address:${addr}'})"
    hyprctl dispatch "hl.dsp.focus({window='address:${addr}'})"
fi
