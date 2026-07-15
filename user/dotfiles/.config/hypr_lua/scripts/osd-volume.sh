#! /usr/bin/env bash
set -euo pipefail

SINK="@DEFAULT_AUDIO_SINK@"
STEP="5%"
MAX_VOLUME="1.0"
NOTIFY_TAG="volume-osd"
TIMEOUT_MS=900

play_feedback() {
    if command -v canberra-gtk-play >/dev/null 2>&1; then
        canberra-gtk-play -i audio-volume-change -d "volume change" >/dev/null 2>&1 &
    fi
}

notify_volume() {
    local status muted volume percent icon title body

    status="$(wpctl get-volume "$SINK")"
    muted=false
    if [[ "$status" == *"[MUTED]"* ]]; then
        muted=true
    fi

    volume="$(awk '{ print $2 }' <<< "$status")"
    percent="$(awk -v volume="$volume" 'BEGIN { printf "%d", (volume * 100) + 0.5 }')"

    if [[ "$muted" == true ]]; then
        icon="audio-volume-muted-symbolic"
        title="Muted"
        body="Volume ${percent}%"
        percent=0
    elif (( percent >= 66 )); then
        icon="audio-volume-high-symbolic"
        title="Volume"
        body="${percent}%"
    elif (( percent >= 33 )); then
        icon="audio-volume-medium-symbolic"
        title="Volume"
        body="${percent}%"
    elif (( percent > 0 )); then
        icon="audio-volume-low-symbolic"
        title="Volume"
        body="${percent}%"
    else
        icon="audio-volume-muted-symbolic"
        title="Volume"
        body="0%"
    fi

    notify-send \
        --app-name="System OSD" \
        --urgency=low \
        --expire-time="$TIMEOUT_MS" \
        --icon="$icon" \
        --hint="string:x-canonical-private-synchronous:${NOTIFY_TAG}" \
        --hint="int:value:${percent}" \
        "$title" "$body"
}

case "${1:-}" in
    up)
        wpctl set-volume -l "$MAX_VOLUME" "$SINK" "${STEP}+"
        play_feedback
        ;;
    down)
        wpctl set-volume "$SINK" "${STEP}-"
        play_feedback
        ;;
    mute)
        wpctl set-mute "$SINK" toggle
        play_feedback
        ;;
    *)
        echo "Usage: $0 {up|down|mute}" >&2
        exit 2
        ;;
esac

notify_volume
