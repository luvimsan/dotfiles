#!/usr/bin/env bash

if [[ -d /sys/class/net/proton ]]; then
    echo "▲"
else
    echo "▼"
fi
