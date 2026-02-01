#!/usr/bin/env bash

mkdir -p ~/Pictures/Screenshots
FILE=~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png
echo "$FILE" | xclip -selection clipboard
maim -u -i $(xdotool getactivewindow) | tee  $FILE| xclip -selection clipboard -t image/png
