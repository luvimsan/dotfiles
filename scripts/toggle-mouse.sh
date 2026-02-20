#!/usr/bin/env bash

MOUSE_DEVICES=(
    "YICHIP Wireless Device Mouse"
    "YICHIP Wireless Device Consumer Control"
    "SynPS/2 Synaptics TouchPad"
)

FIRST_DEVICE="${MOUSE_DEVICES[0]}"
CURRENT_STATE=$(xinput list-props "$FIRST_DEVICE" | grep "Device Enabled" | awk '{print $4}')

if [ "$CURRENT_STATE" == "1" ]; then
    # Disable all mouse devices
    for device in "${MOUSE_DEVICES[@]}"; do
        xinput set-prop "$device" "Device Enabled" 0 2>/dev/null
    done
    notify-send "Mouse Input" "Disabled"
else
    # Enable all mouse devices
    for device in "${MOUSE_DEVICES[@]}"; do
        xinput set-prop "$device" "Device Enabled" 1 2>/dev/null
    done
    notify-send "Mouse Input" "Enabled"
fi
