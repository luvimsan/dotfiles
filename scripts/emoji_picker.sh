#!/usr/bin/env bash

emoji_file="$HOME/.config/emojis.txt"
choice=$(cat "$emoji_file" | dmenu -i -l 7 -p "Emoji:")
printf '%s' "$choice" | awk '{print $NF}' | tr -d '\n' | xclip -selection clipboard
