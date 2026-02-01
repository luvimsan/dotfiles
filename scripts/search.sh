#!/usr/bin/env bash

input="$(dmenu -p "🔍 Search:" < /dev/null)"
[ -z "$input" ] && exit 0

prev=$input

url-cases() {
    if echo "$input" | grep -q '^ *!'; then
        input="https://duckduckgo.com/?q=$(printf "%s" "$input" | jq -s -R -r @uri)"
    elif echo "$input" | grep -Eiq '^[a-zA-Z]+://|localhost|[^ ]+\.[^ ]+'; then
        if echo "$input" | grep -Eiq '^localhost'; then
            input="http://$input"
        elif ! echo "$input" | grep -Eiq '^[a-zA-Z]+://'; then
            input="https://$input"
        fi
    else
        input="https://www.google.com/search?udm=14&q=$(printf "%s" "$input" | jq -s -R -r @uri)"
    fi
}

shortcuts() {
    case "$input" in
        *' 'mo) input="https://monkeytype.com";;
        *' 'yt) input="https://youtube.com";;
        *' 're) input="https://reddit.com";;
        *' 'ch) input="https://chatgpt.com";;
        *' 'de) input="https://deepseek.com";;
    esac
}

if echo "$prev" | grep -q '^ '; then
    shortcuts && url-cases
    brave --incognito "$input" & disown
    xdotool key super+1
    exit
else
    shortcuts && url-cases
    "$BROWSER" "$input" & disown
    xdotool key super+1
fi
