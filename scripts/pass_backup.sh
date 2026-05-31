#!/usr/bin/env bash

PASS_PATH="$HOME/.password-store"

cd "$PASS_PATH" || exit

git add .
git commit -m "Pass backup: $(date '+%Y-%m-%d %H:%M')"
git push origin main
