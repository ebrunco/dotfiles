#!/usr/bin/env bash
notif="$HOME/.config/swaync/images/ja.png"
state_file="/tmp/sway_gamemode"

if [[ -f "$state_file" ]]; then
    rm "$state_file"
    swaymsg gaps inner all set 3
    swaymsg gaps outer all set 3
    swaymsg default_border pixel 1
    notify-send -e -u normal -i "$notif" " Gamemode:" " disabled"
else
    touch "$state_file"
    swaymsg gaps inner all set 0
    swaymsg gaps outer all set 0
    swaymsg default_border none
    notify-send -e -u low -i "$notif" " Gamemode:" " enabled"
fi
