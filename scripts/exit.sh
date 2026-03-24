#!/usr/bin/env bash

choice=$(printf "⏻  shutdown\n  reboot\n☾ hibernate\n  logout" | dmenu -i -l 4 -p "Choose:")

[ "$choice" = "⏻  shutdown" ] && doas poweroff
[ "$choice" = "  reboot" ] && doas reboot
[ "$choice" = "☾  hibernate" ] && doas systemctl hibernate
[ "$choice" = "  logout" ] && pkill dwm
