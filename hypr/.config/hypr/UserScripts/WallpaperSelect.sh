#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Wallpaper selector (SUPER W) — adapted from upstream, uses awww

wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

iDIR="$HOME/.config/swaync/images"

SWWW_PARAMS="--transition-type none"

rofi_config="$HOME/.config/rofi/config-wallpaper.rasi"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

if [[ -z "$focused_monitor" ]]; then
  notify-send -i "$iDIR/error.png" "Error" "Could not detect focused monitor"
  exit 1
fi

scale_factor=$(hyprctl monitors -j | jq -r --arg m "$focused_monitor" '.[] | select(.name == $m) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg m "$focused_monitor" '.[] | select(.name == $m) | .height')

icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

mapfile -d '' PICS < <(find -L "$wallDIR" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)

if [[ ${#PICS[@]} -eq 0 ]]; then
  notify-send -i "$iDIR/error.png" "No wallpapers" "No images found in $wallDIR"
  exit 1
fi

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

kill_wallpaper_for_image() {
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

kill_wallpaper_for_video() {
  awww kill 2>/dev/null
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

menu() {
  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

  IFS=$'\n' sorted=($(sort <<<"${PICS[*]}"))
  for pic in "${sorted[@]}"; do
    name=$(basename "$pic")
    if [[ "$name" =~ \.gif$ ]]; then
      cache="$HOME/.cache/gif_preview/${name}.png"
      if [[ ! -f "$cache" ]]; then
        mkdir -p "$HOME/.cache/gif_preview"
        magick "$pic[0]" -resize 1920x1080 "$cache" 2>/dev/null
      fi
      printf "%s\x00icon\x1f%s\n" "$name" "$cache"
    elif [[ "$name" =~ \.(mp4|mkv|mov|webm)$ ]]; then
      cache="$HOME/.cache/video_preview/${name}.png"
      if [[ ! -f "$cache" ]]; then
        mkdir -p "$HOME/.cache/video_preview"
        ffmpeg -v error -y -i "$pic" -ss 1 -vframes 1 "$cache" 2>/dev/null
      fi
      printf "%s\x00icon\x1f%s\n" "$name" "$cache"
    else
      printf "%s\x00icon\x1f%s\n" "$name" "$pic"
    fi
  done
}

apply_image_wallpaper() {
  kill_wallpaper_for_image
  pgrep -x "awww-daemon" >/dev/null || awww-daemon --format xrgb &
  awww img -o "$focused_monitor" "$1" $SWWW_PARAMS
  ln -sf "$1" "$HOME/.config/rofi/.current_wallpaper"
}

apply_video_wallpaper() {
  kill_wallpaper_for_video
  mpvpaper '*' -o "load-scripts=no no-audio --loop" "$1" &
  ln -sf "$1" "$HOME/.config/rofi/.current_wallpaper"
}

main() {
  current_wall=$(readlink "$HOME/.config/rofi/.current_wallpaper" 2>/dev/null)
  current_name=$(basename "$current_wall" 2>/dev/null)

  rofi_select_args=()
  if [[ -n "$current_name" ]]; then
    rofi_select_args=(-select "$current_name")
  fi

  choice=$(menu | rofi -i -show -dmenu -config "$rofi_config" -theme-str "$rofi_override" "${rofi_select_args[@]}")
  choice=$(echo "$choice" | xargs)

  [[ -z "$choice" ]] && exit 0

  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    selected="$RANDOM_PIC"
  else
    selected=""
    for pic in "${PICS[@]}"; do
      if [[ "$(basename "$pic")" == "$choice" ]]; then
        selected="$pic"
        break
      fi
    done
  fi

  if [[ ! -f "$selected" ]]; then
    notify-send -i "$iDIR/error.png" "Error" "Wallpaper not found: $choice"
    exit 1
  fi

  if [[ "$selected" =~ \.(mp4|mkv|mov|webm|MP4|MKV|MOV|WEBM)$ ]]; then
    apply_video_wallpaper "$selected"
  else
    apply_image_wallpaper "$selected"
  fi
}

pidof rofi >/dev/null && pkill rofi
main
