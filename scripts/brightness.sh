#!/usr/bin/env bash

STEP="2%"
STATE_FILE="$HOME/.brightness_level"
ID_FILE="/tmp/bright_notify_id"
ICON="🌞"

case "$1" in
  up)   doas brightnessctl set +"$STEP" ;;
  down) doas brightnessctl set "$STEP"- ;;
  *) exit 1 ;;
esac

current=$(brightnessctl get)
max=$(brightnessctl max)

echo "$current" > "$STATE_FILE"

percent=$(( current * 100 / max ))

[ -f "$ID_FILE" ] && id=$(cat "$ID_FILE") || id=0

newid=$(dunstify \
  -r "$id" \
  -h string:x-canonical-private-synchronous:brightness \
  -h int:value:"$percent" \
  -u low \
  -t 800 \
  -p \
  "$ICON Brightness: ${percent}%")

echo "$newid" > "$ID_FILE"
