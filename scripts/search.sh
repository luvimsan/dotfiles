#!/usr/bin/env bash

raw_input="$(dmenu -p "🔍 Search:" < /dev/null)"
[ -z "$raw_input" ] && exit 0

incognito=false
[[ "$raw_input" =~ ^[[:space:]] ]] && incognito=true

input="${raw_input#"${raw_input%%[![:space:]]*}"}"
input="${input%"${input##*[![:space:]]}"}"

case "$input" in
    mo) input="https://monkeytype.com" ;;
    yt) input="https://youtube.com" ;;
    re) input="https://reddit.com" ;;
    ch) input="https://chatgpt.com" ;;
    de) input="https://deepseek.com" ;;
    li) input="https://lichess.org" ;;
    x)  input="https://x.com" ;;
    sc) input="https://365scores.com/ar" ;;
    wh) input="https://web.whatsapp.com" ;;
    *)
        if [[ "$input" =~ ^! ]] || [[ "$input" =~ ^[a-zA-Z]+://|localhost|[^[:space:]]+\.[^[:space:]]+ ]]; then
            if [[ "$input" =~ ^localhost ]]; then
                input="http://$input"
            elif ! [[ "$input" =~ ^[a-zA-Z]+:// ]]; then
                input="https://$input"
            fi
        else
            if [[ "$input" == *" g" ]]; then
                query="${input% g}"
                input="https://www.google.com/search?udm=14&q=${query// /+}"
            elif [[ "$input" == *" d" ]]; then
                query="${input% d}"
                input="https://duckduckgo.com/?q=${query// /+}&ia=web"
            else
                input="https://lite.duckduckgo.com/lite?q=${input// /+}"
            fi
        fi
        ;;
esac

sleep 0.1
xdotool key super+1

if [ "$incognito" = true ]; then
    brave --incognito "$input" & disown
else
    "${BROWSER:-xdg-open}" "$input" & disown
fi
