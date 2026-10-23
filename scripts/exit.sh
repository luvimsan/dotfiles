#!/usr/bin/env bash

choice=$(printf "⏻  shutdown\n  reboot\n☾  hibernate\n󰤄 sleep\n  logout" | dmenu -i -l 5 -p "Choose:")

[ "$choice" = "⏻  shutdown" ] && doas poweroff
[ "$choice" = "  reboot" ] && doas reboot
[ "$choice" = "☾  hibernate" ] && doas systemctl hibernate
[ "$choice" = "󰤄 sleep" ] && doas systemctl suspend
[ "$choice" = "  logout" ] && loginctl terminate-session self
