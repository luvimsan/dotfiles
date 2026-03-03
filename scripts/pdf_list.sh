#!/usr/bin/env bash

USAGE_FILE="$HOME/.local/share/pdf_usage.txt"

mkdir -p "$(dirname "$USAGE_FILE")"
touch "$USAGE_FILE"

category=$(printf "Deen\nProgramming\nGeneral\nChess\nDownloads" | dmenu -i -l 7 -p "PDF:")
[ -z "$category" ] && exit

case "$category" in
    Deen)
        pdf_list=$(find ~/personal/deen/pdfs -type f -name "*.pdf" 2>/dev/null);;
    Programming)
        pdf_list=$(find ~/personal/books/programming -type f -name "*.pdf" 2>/dev/null);;
    General)
        pdf_list=$(find ~/personal/books/general -type f -name "*.pdf" 2>/dev/null);;
    Chess)
        pdf_list=$(find ~/personal/books/chess -type f -name "*.pdf" 2>/dev/null);;
    Downloads)
        pdf_list=$(find ~/Downloads -type f -name "*.pdf" 2>/dev/null);;
esac

menu=$(awk -F'|' -v pdfs="$pdf_list" '
BEGIN {
    split(pdfs, arr, "\n")
    for (i in arr) if (arr[i] != "") {
        usage[arr[i]] = 0
        name = arr[i]
        sub(/^.*\//, "", name)
        sub(/\.pdf$/, "", name)
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

selection=$(echo "$menu" | cut -f1 | dmenu -i -l 7 -p "Open PDF:")
[ -z "$selection" ] && exit

file=$(echo "$menu" | awk -F '\t' -v sel="$selection" '$1==sel {print $2}')

if [ -n "$file" ] && [ -f "$file" ]; then
    xdotool key super+9

    count=$(awk -F'|' -v f="$file" '$2==f {print $1}' "$USAGE_FILE")

    count=${count:-0}
    count=$((count+1))

    awk -F'|' -v f="$file" '$2!=f' "$USAGE_FILE" > "$USAGE_FILE.tmp"

    echo "$count|$file" >> "$USAGE_FILE.tmp"
    mv "$USAGE_FILE.tmp" "$USAGE_FILE"

    zathura "$file" &
fi

