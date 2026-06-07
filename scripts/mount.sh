#!/usr/bin/env bash

uid=$(id -u)
gid=$(id -g)

usbdev=$(lsblk -rno NAME,TRAN | awk '$2=="usb" {print "/dev/"$1}')

if [ -n "$usbdev" ]; then
    selected=$( \
        { echo "all"; lsblk -rno NAME,SIZE,MOUNTPOINT $usbdev; } | \
        awk '{printf "%-7s %-7s %s\n", $1, $2, $3}' | \
        dmenu -l 6 -i -p "USB Drives:" | awk '{print $1}'
    )

    if [ -z "$selected" ]; then
        exit 1
    fi

    if [[ "$selected" == all* ]]; then
        targets=$(lsblk -rno NAME,TYPE $usbdev | awk '$2=="part" {print $1}')
    else
        targets="$selected"
    fi

    for target in $targets; do
        label=$(lsblk -rno LABEL "/dev/$target")
        if [ -n "$label" ]; then
            mnt_path="/mnt/$label"
        else
            mnt_path="/mnt/$target"
        fi

        if [ -d "$mnt_path" ] && ! mountpoint -q "$mnt_path"; then
            doas rm -rf "$mnt_path"
        fi

        if grep -qs "/dev/$target" /proc/mounts; then
            sync
            doas fuser -k -m "$mnt_path" 2>/dev/null
            doas umount "/dev/$target" || doas umount -l "/dev/$target"
            doas rm -rf "$mnt_path"
        else
            [ ! -d "$mnt_path" ] && doas mkdir -p "$mnt_path"
            doas mount -o uid=$uid,gid=$gid "/dev/$target" "$mnt_path"
        fi
    done
else
    echo "No drives connected" | dmenu -i -p "USB Drives: "
    exit 1
fi
