#!/usr/bin/env bash

vpn_file="/sys/class/net/proton"

if [[ -d $vpn_file ]]; then
    doas wg-quick down proton
    for i in {1..20}; do
        [[ ! -d $vpn_file ]] && break
        sleep 0.1
    done
else
    doas wg-quick up proton
    for i in {1..20}; do
        [[ -d $vpn_file ]] && break
        sleep 0.1
    done
fi

pkill -RTMIN+25 dwmblocks
