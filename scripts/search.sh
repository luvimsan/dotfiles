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
        case "$input" in
            *" g")
                query="${input% g}"
                input="https://www.google.com/search?udm=14&q=$(printf "%s" "$query" | jq -s -R -r @uri)"
                ;;
            *" n")
                query="${input% l}"
                input="https://duckduckgo.com/?q=$(printf "%s" "$query" | jq -s -R -r @uri)";;
            *) input="https://lite.duckduckgo.com/lite?q=$(printf "%s" "$input" | jq -s -R -r @uri)";;
        esac
    fi
}

shortcuts() {
    input=$(echo "$input" | xargs)
    case "$input" in
        mo) input="https://monkeytype.com";;
        yt) input="https://youtube.com";;
        re) input="https://reddit.com";;
        ch) input="https://chatgpt.com";;
        de) input="https://deepseek.com";;
        li) input="https://lichess.org";;
        x) input="https://x.com";;
        sc) input="https://365scores.com/ar";;
        wh) input="https://web.whatsapp.com";;
        *) ;;
    esac
}

if echo "$prev" | grep -q '^ '; then
    xdotool key super+1
    shortcuts && url-cases
    brave --incognito "$input" & disown
else
    xdotool key super+1
    shortcuts && url-cases
    "$BROWSER" "$input" & disown
fi
