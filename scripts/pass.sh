#!/usr/bin/env bash

PASS_DIR="$HOME/.password-store"

entry=$(find "$PASS_DIR" -name "*.gpg" \
  | sed "s|$PASS_DIR/||; s|\.gpg$||" \
  | dmenu -i -l 8 -p "Pass:")

[ -z "$entry" ] && exit

action=$(printf "password\notp" | dmenu -i -l 2 -p "Copy:")

[ -z "$action" ] && exit

clipctl disable

case "$action" in
  password)
    pass show -c "$entry" 2>/dev/null
    ;;
  otp)
    pass otp -c "$entry" 2>/dev/null
    ;;
esac

clipctl enable

