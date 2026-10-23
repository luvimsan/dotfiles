#!/usr/bin/env bash

input="$(dmenu -p "Video URL:" < /dev/null)" || exit 0

mpv "$input"
