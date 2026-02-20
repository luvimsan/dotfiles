#!/usr/bin/env bash

cd "$(tmux display-message -p "#{pane_current_path}")" || exit
url="$(git remote get-url origin)"

if [[ $url == *github.com* ]]; then
    if [[ $url == git@* ]]; then
        url="${url#git@}"
        url="${url/:/\/}"
        url="https://${url%.git}"
    fi
    xdotool key super+1
    "$BROWSER" "$url" > /dev/null 2>&1 & disown
else
    echo "This repo is not hosted on github"
fi
