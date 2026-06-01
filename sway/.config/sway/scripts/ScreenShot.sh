#!/usr/bin/env bash
# Requires: grim, slurp, jq, swappy (optional), notify-send

time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}_${RANDOM}.png"
mkdir -p "$dir"

iDIR="$HOME/.config/swaync/icons"
iDoR="$HOME/.config/swaync/images"
sDIR="$HOME/.config/sway/scripts"

active_window_class=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // .window_properties.class // "window"' | head -1)
active_window_file="Screenshot_${time}_${active_window_class}.png"
active_window_path="${dir}/${active_window_file}"

notify_cmd="notify-send -t 10000 -A action1=Open -A action2=Delete -h string:x-canonical-private-synchronous:shot-notify -i ${iDIR}/picture.png"

notify_view() {
    local path="$1" label="$2"
    if [[ -e "$path" ]]; then
        "${sDIR}/Sounds.sh" --screenshot 2>/dev/null
        resp=$(timeout 5 $notify_cmd " Screenshot" " ${label} Saved.")
        case "$resp" in
            action1) xdg-open "$path" & ;;
            action2) rm "$path" ;;
        esac
    else
        notify-send -u low -i "${iDoR}/note.png" " Screenshot" " NOT Saved."
        "${sDIR}/Sounds.sh" --error 2>/dev/null
    fi
}

case "$1" in
    --now)
        grim "${dir}/${file}" && notify_view "${dir}/${file}" "$file"
        ;;
    --area)
        grim -g "$(slurp)" "${dir}/${file}" && notify_view "${dir}/${file}" "$file"
        ;;
    --active)
        geom=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | head -1)
        grim -g "$geom" "$active_window_path" && notify_view "$active_window_path" "$active_window_class"
        ;;
    --in5)
        notify-send -u low "Screenshot in 5s..."; sleep 5
        grim "${dir}/${file}" && notify_view "${dir}/${file}" "$file"
        ;;
    --in10)
        notify-send -u low "Screenshot in 10s..."; sleep 10
        grim "${dir}/${file}" && notify_view "${dir}/${file}" "$file"
        ;;
    --swappy)
        grim -g "$(slurp)" - | swappy -f -
        ;;
    *)
        echo "Usage: $0 --now | --area | --active | --in5 | --in10 | --swappy"
        exit 1
        ;;
esac
