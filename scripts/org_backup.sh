#!/usr/bin/env bash

ORG_PATH="$HOME/org"

cd "$ORG_PATH" || exit

git add .
git commit -m "Org backup: $(date '+%Y-%m-%d %H:%M')"
git push origin main
