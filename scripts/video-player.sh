#!/usr/bin/env bash

input="$(dmenu -p "Video URL:" < /dev/null)" || exit 0
notify-send -t 18000 "The video is loading..."

mpv "$input"
