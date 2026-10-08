#!/usr/bin/env bash
STEP=5%
SINK=@DEFAULT_AUDIO_SINK@
CACHE="${XDG_RUNTIME_DIR:-/tmp}/volume_status"

case "$1" in
  up)     wpctl set-volume -l 1.0 "$SINK" "${STEP}+" ;;
  down)   wpctl set-volume "$SINK" "${STEP}-" ;;
  toggle) wpctl set-mute   "$SINK" toggle ;;
  *) exit 1 ;;
esac

status=$(wpctl get-volume "$SINK")
vol=$(awk '{print int($2*100)}' <<< "$status")
[[ "$status" == *MUTED* ]] && icon="🔇" || icon="🔊"

echo "$icon ${vol}%" > "$CACHE"
dunstify -a "volume" -u low -t 700 \
  -h string:x-dunst-stack-tag:volume \
  -h int:value:"$vol" \
  "$icon Volume: ${vol}%"
pkill -RTMIN+30 -x dwmblocks
