#!/usr/bin/env bash
STEP=5%
SINK=@DEFAULT_AUDIO_SINK@

case "$1" in
  up)
    current=$(wpctl get-volume "$SINK" | awk '{print int($2*100)}')
    (( current < 100 )) && wpctl set-volume "$SINK" "$STEP+"
    ;;
  down)  wpctl set-volume "$SINK" "$STEP-" ;;
  toggle) wpctl set-mute  "$SINK" toggle ;;
  *) exit 1 ;;
esac

status=$(wpctl get-volume "$SINK")
vol=$(awk '{print int($2*100)}' <<< "$status")
[[ "$status" == *MUTED* ]] && icon="🔇" || icon="🔊"

# notify-send \
#   -h string:x-canonical-private-synchronous:volume \
#   -h int:value:"$vol" \
#   -u low -t 700 \
#   "$icon Volume: ${vol}%"

dunstify -r 9999 -u low -t 700 "$icon Volume: ${vol}%"

kill -RTMIN+30 "$(pidof dwmblocks)" 2>/dev/null
