#!/usr/bin/env bash
A_2160=600; B_2160=600
A_1600=400; B_1600=400
A_1440=400; B_1440=400
A_1080=200; B_1080=200
A_720=50;   B_720=50

if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"; exit 0
fi

resolution=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused==true) | .current_mode.height / .scale' | awk -F'.' '{print $1}')
sway_scale=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused==true) | .scale')

if ((resolution >= 2160)); then
    T=$(awk "BEGIN {printf \"%.0f\", $A_2160*2160*$sway_scale/$resolution}")
    B=$(awk "BEGIN {printf \"%.0f\", $B_2160*2160*$sway_scale/$resolution}")
    wlogout --protocol layer-shell -b 6 -T "$T" -B "$B" &
elif ((resolution >= 1600)); then
    T=$(awk "BEGIN {printf \"%.0f\", $A_1600*1600*$sway_scale/$resolution}")
    B=$(awk "BEGIN {printf \"%.0f\", $B_1600*1600*$sway_scale/$resolution}")
    wlogout --protocol layer-shell -b 6 -T "$T" -B "$B" &
elif ((resolution >= 1440)); then
    T=$(awk "BEGIN {printf \"%.0f\", $A_1440*1440*$sway_scale/$resolution}")
    B=$(awk "BEGIN {printf \"%.0f\", $B_1440*1440*$sway_scale/$resolution}")
    wlogout --protocol layer-shell -b 6 -T "$T" -B "$B" &
elif ((resolution >= 1080)); then
    T=$(awk "BEGIN {printf \"%.0f\", $A_1080*1080*$sway_scale/$resolution}")
    B=$(awk "BEGIN {printf \"%.0f\", $B_1080*1080*$sway_scale/$resolution}")
    wlogout --protocol layer-shell -b 6 -T "$T" -B "$B" &
elif ((resolution >= 720)); then
    T=$(awk "BEGIN {printf \"%.0f\", $A_720*720*$sway_scale/$resolution}")
    B=$(awk "BEGIN {printf \"%.0f\", $B_720*720*$sway_scale/$resolution}")
    wlogout --protocol layer-shell -b 3 -T "$T" -B "$B" &
else
    wlogout &
fi
