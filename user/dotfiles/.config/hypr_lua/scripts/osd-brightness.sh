#! /usr/bin/env bash
set -euo pipefail

STEP="5%"
NOTIFY_TAG="brightness-osd"
TIMEOUT_MS=900

notify_brightness() {
    local percent icon

    percent="$(brightnessctl -m | awk -F, '{ gsub("%", "", $4); print $4 }')"

    if (( percent >= 66 )); then
        icon="display-brightness-high-symbolic"
    elif (( percent >= 33 )); then
        icon="display-brightness-medium-symbolic"
    else
        icon="display-brightness-low-symbolic"
    fi

    notify-send \
        --app-name="System OSD" \
        --urgency=low \
        --expire-time="$TIMEOUT_MS" \
        --icon="$icon" \
        --hint="string:x-canonical-private-synchronous:${NOTIFY_TAG}" \
        --hint="int:value:${percent}" \
        "Brightness" "${percent}%"
}

case "${1:-}" in
    up)
        brightnessctl set "${STEP}+"
        ;;
    down)
        brightnessctl set "${STEP}-"
        ;;
    *)
        echo "Usage: $0 {up|down}" >&2
        exit 2
        ;;
esac

notify_brightness
