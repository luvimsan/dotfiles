#!/usr/bin/env bash

raw_input="$(dmenu -p "🔍 Search:" < /dev/null)"
[ -z "$raw_input" ] && exit 0

incognito=false
echo "$raw_input" | grep -q '^ ' && incognito=true

input="$(echo "$raw_input" | xargs)"

shortcuts() {
    case "$input" in
        mo) input="https://monkeytype.com"; return 0 ;;
        yt) input="https://youtube.com"; return 0 ;;
        re) input="https://reddit.com"; return 0 ;;
        ch) input="https://chatgpt.com"; return 0 ;;
        de) input="https://deepseek.com"; return 0 ;;
        li) input="https://lichess.org"; return 0 ;;
        x)  input="https://x.com"; return 0 ;;
        sc) input="https://365scores.com/ar"; return 0 ;;
        wh) input="https://web.whatsapp.com"; return 0 ;;
        *)  return 1 ;;
    esac
}

url-cases() {
    if echo "$input" | grep -q '^!'; then
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
            *" l")
                query="${input% l}"
                input="https://lite.duckduckgo.com/lite?q=$(printf "%s" "$query" | jq -s -R -r @uri)"
                ;;
            *)
                input="https://duckduckgo.com/?q=$(printf "%s" "$input" | jq -s -R -r @uri)"
                ;;
        esac
    fi
}

xdotool key super+1
shortcuts || url-cases

if [ "$incognito" = true ]; then
    brave --incognito "$input" & disown
else
    "${BROWSER:-xdg-open}" "$input" & disown
fi
