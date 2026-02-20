#!/usr/bin/env bash

USAGE_FILE="$HOME/.local/share/video_usage.txt"

mkdir -p "$(dirname "$USAGE_FILE")"
touch "$USAGE_FILE"

category=$(printf "Fun\nProgramming\nSahm\nTsoding\nPoems\nChess" | dmenu -i -l 7 -p "Video:")
[ -z "$category" ] && exit

case "$category" in
    Fun)
        video_list=$(find ~/personal/courses/fun/general -type f -name "*.mp4" 2>/dev/null);;
    Programming)
        video_list=$(find ~/personal/courses -maxdepth 2 -type f -name "*.mp4" 2>/dev/null)
        video_list+=" $(find /media/fun/_luvimsan/1.Programming -maxdepth 3 -type f -name "*.mp4" 2>/dev/null)";;
    Sahm)
        video_list=$(find ~/personal/courses/fun/sahm -maxdepth 1 -type f -name "*.mp4" 2>/dev/null);;
    Tsoding)
        video_list=$(find ~/personal/courses/fun/tsoding -maxdepth 1 -type f -name "*.mp4" 2>/dev/null);;
    Poems)
        video_list=$(find ~/personal/courses/fun/osama -maxdepth 1 -type f -name "*.mp4" 2>/dev/null);;
    Chess)
        video_list=$(find /media/fun/_luvimsan/5.Chess -type f -name "*.mp4" 2>/dev/null);;
esac

menu=$(awk -F'|' -v videos="$video_list" '
BEGIN {
    split(videos, arr, "\n")
    for (i in arr) if (arr[i] != "") {
        usage[arr[i]] = 0
        name = arr[i]
        sub(/^.*\//, "", name)
        sub(/\.mp4$/, "", name)
        title[arr[i]] = name
    }
}
{
    if ($2 in usage) {
        usage[$2] = $1
    }
}
END {
    for (f in usage) {
        print usage[f] "\t" title[f] "\t" f
    }
}' "$USAGE_FILE" | sort -nr | cut -f2-)

selection=$(echo "$menu" | cut -f1 | dmenu -i -l 7 -p "Open mpv:")
[ -z "$selection" ] && exit

file=$(echo "$menu" | awk -F '\t' -v sel="$selection" '$1==sel {print $2}')

if [ -n "$file" ] && [ -f "$file" ]; then
    xdotool key super+2

    count=$(awk -F'|' -v f="$file" '$2==f {print $1}' "$USAGE_FILE")

    count=${count:-0}
    count=$((count+1))

    awk -F'|' -v f="$file" '$2!=f' "$USAGE_FILE" > "$USAGE_FILE.tmp"

    echo "$count|$file" >> "$USAGE_FILE.tmp"
    mv "$USAGE_FILE.tmp" "$USAGE_FILE"

    mpv "$file"
fi

