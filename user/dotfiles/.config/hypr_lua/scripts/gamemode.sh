#!/usr/bin/env bash
# =============================================================================
# Hyprland Game Mode Toggle Script (Compatible with Lua Configuration)
# =============================================================================

STATE_FILE="/tmp/hypr_gamemode.state"

if [ ! -f "$STATE_FILE" ]; then
    # ------------------
    # 进入游戏模式
    # ------------------
    touch "$STATE_FILE"

    # 使用 Lua 配置接口关闭特效、动画、圆角、边距；保持合成器同步。
    hyprctl eval 'hl.config({
        general = {
            gaps_in = 0,
            gaps_out = 0,
            border_size = 1,
            allow_tearing = false,
        },
        decoration = {
            rounding = 0,
            blur = { enabled = false },
            shadow = { enabled = false },
        },
        animations = {
            enabled = false,
        },
    })'

    # 暂停 hypridle（防止手柄玩游戏或看剧情时屏幕自动休眠）
    pkill -STOP hypridle 2>/dev/null || true

    notify-send -a "Hyprland GameMode" -u low -t 2000 -i input-gaming \
        "🎮 游戏模式已开启" "已关闭动画、模糊、阴影并禁用息屏"
else
    # ------------------
    # 退出游戏模式
    # ------------------
    rm -f "$STATE_FILE"

    # 重载 Lua 配置恢复所有原有特效、动画与主题
    hyprctl reload

    # 恢复 hypridle 监听
    pkill -CONT hypridle 2>/dev/null || true

    notify-send -a "Hyprland GameMode" -u low -t 2000 -i video-display \
        "🖥 游戏模式已关闭" "已恢复桌面特效与正常息屏策略"
fi
