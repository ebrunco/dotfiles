#!/usr/bin/env bash
pkill waybar; pkill swaync; pkill rofi
sleep 0.1
waybar &
sleep 0.3
swaync >/dev/null 2>&1 &
swaync-client --reload-config
