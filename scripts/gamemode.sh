#!/bin/bash

echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
sudo sysctl vm.swappiness=10

echo "--- Performance Mode Active ---"

