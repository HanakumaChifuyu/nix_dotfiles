#!/usr/bin/env bash

# Display width budget (e.g. 24 means ~24 ASCII chars or ~12 CJK chars)
MAX_WIDTH=24

# Display width using `wc -L` (handles CJK / fullwidth correctly under UTF-8 locale)
dwidth() {
    printf '%s' "$1" | wc -L
}

# Normalize titles so Waybar never receives embedded line breaks or tabs.
normalize_text() {
    tr '\r\n\t' '   ' <<< "$1" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

# Escape Pango markup text.
escape_markup() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<< "$1"
}

# Truncate to display width N, append "..." if cut.
truncate_dw() {
    local s="$1" n="$2"
    local total
    total=$(dwidth "$s")
    if (( total <= n )); then
        printf '%s' "$s"
        return
    fi
    local limit=$((n - 3))
    local out="" cur=""
    local i=0 len=${#s}
    while (( i < len )); do
        cur="${s:0:i+1}"
        if (( $(dwidth "$cur") > limit )); then
            break
        fi
        out="$cur"
        ((i++))
    done
    printf '%s...' "$out"
}

print_status() {
    window=$(hyprctl activewindow -j 2>/dev/null)
    address=$(jq -r '.address // empty' <<< "$window")

    # No active window → show Desktop + Workspace
    if [[ -z "$address" || "$address" == "null" ]]; then
        ws=$(hyprctl activeworkspace -j | jq -r '.id')

        line=$(truncate_dw "Desktop - Workspace $ws" "$MAX_WIDTH")
        esc_line=$(escape_markup "$line")
        text="<span size='9000' weight='bold' foreground='#ffffff'>$esc_line</span>"

        jq -nc \
            --arg text "$text" \
            --arg tooltip "Workspace $ws" \
            '{ text: $text, class: "custom-window", tooltip: $tooltip }'
        return
    fi

    class=$(jq -r '.class // "Unknown"' <<< "$window")
    title=$(normalize_text "$(jq -r '.title // ""' <<< "$window")")

    app_class="${class,,}"

    # Discord / Vesktop cleanup
    if [[ "$app_class" == *discord* || "$app_class" == *vesktop* ]]; then
        title=$(sed -E 's/^\([0-9]+\)[[:space:]]*//' <<< "$title")
        title=$(sed -E 's/^Discord[[:space:]]*\|[[:space:]]*//' <<< "$title")
    fi

    tooltip="$class: $title"

    line=$(truncate_dw "$class - $title" "$MAX_WIDTH")
    esc_line=$(escape_markup "$line")
    text="<span size='9000' weight='bold' foreground='#ffffff'>$esc_line</span>"

    jq -nc \
        --arg text "$text" \
        --arg tooltip "$tooltip" \
        '{ text: $text, class: "custom-window", tooltip: $tooltip }'
}

# Initial output
print_status

last=""

# Update only when state changes
while true; do
    current_window=$(hyprctl activewindow -j 2>/dev/null)
    current_ws=$(hyprctl activeworkspace -j 2>/dev/null)

    current="$current_window$current_ws"

    if [[ "$current" != "$last" ]]; then
        print_status
        last="$current"
    fi

    sleep 0.5
done
