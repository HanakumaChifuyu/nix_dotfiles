#!/usr/bin/env bash
# tray-picker — 用 fuzzel 浏览系统托盘进程（含图标）
# 依赖: busctl, fuzzel, wl-copy, libnotify

FUZZEL="fuzzel --dmenu --lines=10 --width=50"

# ── 1. 获取所有已注册 tray items ──────────────────────────────────────────
raw=$(busctl --user get-property \
    org.kde.StatusNotifierWatcher \
    /StatusNotifierWatcher \
    org.kde.StatusNotifierWatcher \
    RegisteredStatusNotifierItems 2>/dev/null)

[[ -z "$raw" ]] && { notify-send "Tray Picker" "StatusNotifierWatcher 未运行"; exit 1; }

mapfile -t items < <(grep -oP '"[^"]+"' <<< "$raw" | tr -d '"')
[[ ${#items[@]} -eq 0 ]] && { notify-send "Tray Picker" "当前没有 tray 进程"; exit 1; }

# ── 2. 对每个 item 查询 SNI 属性，构建 fuzzel 输入 ────────────────────────
# fuzzel dmenu 图标格式: "显示文字\0icon=图标名\n"
declare -A label_to_service
declare -A label_to_pid
declare -A label_to_path
tmp=$(mktemp)

for item in "${items[@]}"; do
    service="${item%%/*}"   # DBus service name（/ 前面部分）
    path="/${item#*/}"     # DBus object path（/ 后面部分，补回斜杠）

    # 查 IconName / Id / Title
    icon=$(busctl --user get-property "$service" "$path" \
        org.kde.StatusNotifierItem IconName 2>/dev/null | grep -oP '"\K[^"]+')
    app_id=$(busctl --user get-property "$service" "$path" \
        org.kde.StatusNotifierItem Id 2>/dev/null | grep -oP '"\K[^"]+')
    title=$(busctl --user get-property "$service" "$path" \
        org.kde.StatusNotifierItem Title 2>/dev/null | grep -oP '"\K[^"]+')

    # 查 PID：具名 service 直接从名字提取；匿名 unique name 走 busctl status
    pid=$(grep -oP 'Item-\K\d+' <<< "$service")
    [[ -z "$pid" ]] && \
        pid=$(busctl --user status "$service" 2>/dev/null | awk -F= '/^PID=/{print $2}')

    procname=$(ps -p "$pid" -o comm= 2>/dev/null)

    # 显示标签：仅展示进程名（若无则退化为 service 名）
    label="${procname:-$service}"

    label_to_service["$label"]="$service"
    label_to_pid["$label"]="$pid"
    label_to_path["$label"]="$path"

    # fuzzel 图标行（无图标时退化为普通文本）
    if [[ -n "$icon" ]]; then
        printf "%s\0icon=%s\n" "$label" "$icon" >> "$tmp"
    else
        printf "%s\n" "$label" >> "$tmp"
    fi
done

# ── 3. 展示选择 ────────────────────────────────────────────────────────────
selected=$($FUZZEL --prompt="󱊖  Tray › " < "$tmp")
rm -f "$tmp"
[[ -z "$selected" ]] && exit 0

service="${label_to_service[$selected]}"
pid="${label_to_pid[$selected]}"
path="${label_to_path[$selected]}"
procname=$(ps -p "$pid" -o comm= 2>/dev/null)

# ── 4. 操作菜单 ────────────────────────────────────────────────────────────
action=$(printf '  点击 (左键)\n  菜单 (右键)\n  Kill\n  复制 service 名\n  DBus 信息' \
    | $FUZZEL --prompt="${procname:-$service} › ")

case "$action" in
    *"点击"*)
        busctl --user call "$service" "$path" org.kde.StatusNotifierItem Activate ii 0 0 2>/dev/null
        ;;
    *"菜单"*)
        busctl --user call "$service" "$path" org.kde.StatusNotifierItem ContextMenu ii 0 0 2>/dev/null
        ;;
    *Kill*)
        [[ -n "$pid" ]] \
            && kill "$pid" && notify-send "Tray Picker" "已终止 ${procname} (PID $pid)" \
            || notify-send "Tray Picker" "找不到 PID"
        ;;
    *"复制"*)
        printf '%s' "$service" | wl-copy
        notify-send "Tray Picker" "已复制: $service"
        ;;
    *"DBus 信息"*)
        info=$(busctl --user status "$service" 2>/dev/null | head -15)
        notify-send "DBus: $service" "$info"
        ;;
esac
