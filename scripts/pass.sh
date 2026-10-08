#!/usr/bin/env bash
PASS_DIR="$HOME/.password-store"

entry=$(find "$PASS_DIR" -name "*.gpg" \
  | sed "s|$PASS_DIR/||; s|\.gpg$||" \
  | dmenu -i -l 8 -p "Pass:")
[ -z "$entry" ] && exit

file_content=$(pass show "$entry" 2>/dev/null)
has_otp=$(echo "$file_content" | grep -i "^otpauth://\|^totp:\|^otp:" | wc -l)
has_username=$(echo "$file_content" | grep -i "^Username:" | wc -l)

if [ "$has_username" -gt 0 ]; then
    username=$(echo "$file_content" | awk -F': ' 'tolower($1) ~ /^username/ {print $2}')
fi

if [ "$has_otp" -gt 0 ] && [ "$has_username" -gt 0 ]; then
    action=$(printf "password\nusername\notp\nboth" | dmenu -i -l 4 -p "Copy:")
elif [ "$has_otp" -gt 0 ]; then
    action=$(printf "password\notp" | dmenu -i -l 2 -p "Copy:")
elif [ "$has_username" -gt 0 ]; then
    action=$(printf "password\nusername" | dmenu -i -l 2 -p "Copy:")
else
    action="password"
fi

[ -z "$action" ] && exit

clipctl disable

save_pass() {
    pass show -c "$entry" 2>/dev/null
    sleep 1 && clipctl enable &
}

save_username() {
    echo -n "$username" | xclip -selection clipboard 2>/dev/null || echo -n "$username" | wl-copy 2>/dev/null
    sleep 1 && clipctl enable &
}

save_otp() {
    pass otp -c "$entry" 2>/dev/null
    sleep 1 && clipctl enable &
}

case "$action" in
  password)
    save_pass
    ;;
  username)
    save_username
    ;;
  otp)
    save_otp
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
