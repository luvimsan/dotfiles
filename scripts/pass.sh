#!/usr/bin/env bash
PASS_DIR="$HOME/.password-store"

entry=$(find "$PASS_DIR" -name "*.gpg" \
  | sed "s|$PASS_DIR/||; s|\.gpg$||" \
  | dmenu -i -l 8 -p "Pass:")
[ -z "$entry" ] && exit

has_otp=$(pass show "$entry" 2>/dev/null | grep -i "^otpauth://\|^totp:\|^otp:" | wc -l)

if [ "$has_otp" -gt 0 ]; then
  action=$(printf "both\npassword\notp" | dmenu -i -l 3 -p "Copy:")
else
  action="password"
fi

[ -z "$action" ] && exit

clipctl disable

save_pass() {
    pass show -c "$entry" 2>/dev/null
    sleep 1 && clipctl enable &
}
case "$action" in
  password)
      save_pass
    ;;
  otp)
      save_pass
    ;;
  both)
    pass show -c "$entry" 2>/dev/null
    notify-send -t 1000 "pass" "Password copied — OTP next in 5s" 2>/dev/null
    sleep 5
    pass otp -c "$entry" 2>/dev/null
    notify-send -t 1000 "pass" "OTP copied" 2>/dev/null
    sleep 1 && clipctl enable &
    ;;
esac
