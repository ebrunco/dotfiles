#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# This script for selecting wallpapers (SUPER W)

# WALLPAPERS PATH
terminal=kitty
wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# swww transition config
FPS=60
TYPE="any"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

# Check if package bc exists
if ! command -v bc &>/dev/null; then
  notify-send -i "$iDIR/error.png" "bc missing" "Install package bc first"
  exit 1
fi

# Variables
rofi_theme="$HOME/.config/rofi/themes/rofi-dark-accent-wallpaper.rasi"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Ensure focused_monitor is detected
if [[ -z "$focused_monitor" ]]; then
  notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Could not detect focused monitor"
  exit 1
fi

# Monitor details
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')

icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

# Kill functions
kill_wallpaper_for_video() {
  swww kill 2>/dev/null
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

kill_wallpaper_for_image() {
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

# Retrieve all wallpapers into an array
mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)

# --- UPDATED: 12 RANDOM SELECTIONS ---
RANDOM_WALLS=()
shuffled=($(printf "%s\n" "${PICS[@]}" | shuf))

# Loop until we have 12 or we run out of files
for ((i=0; i<${#shuffled[@]} && ${#RANDOM_WALLS[@]}<12; i++)); do
    if [[ -f "${shuffled[$i]}" ]]; then
        RANDOM_WALLS+=("${shuffled[$i]}")
    fi
done

# Rofi command
rofi_command="rofi -i -show -dmenu -config $rofi_theme -theme-str $rofi_override"

# Sorting Wallpapers
menu() {
  # 1. Print the 12 Random Options
  for i in "${!RANDOM_WALLS[@]}"; do
    printf "%s. Random\x00icon\x1f%s\n" "$((i+1))" "${RANDOM_WALLS[$i]}"
  done

  # 2. Print alphabetical list
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))
  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    
    if [[ "$pic_name" =~ \.(gif|mp4|mkv|mov|webm)$ ]]; then
      ext="${pic_name##*.}"
      cache_dir="$HOME/.cache/${ext}_preview"
      cache_file="$cache_dir/${pic_name}.png"
      
      if [[ ! -f "$cache_file" ]]; then
        mkdir -p "$cache_dir"
        if [[ "$ext" == "gif" ]]; then
          magick "$pic_path[0]" -resize 1920x1080 "$cache_file" 2>/dev/null
        else
          ffmpeg -v error -y -i "$pic_path" -ss 00:00:01.000 -vframes 1 "$cache_file" 2>/dev/null
        fi
      fi
      [[ -f "$cache_file" ]] && icon="$cache_file" || icon="$pic_path"
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$icon"
    else
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$pic_path"
    fi
  done
}

modify_startup_config() {
  local selected_file="$1"
  local startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
  if [[ "$selected_file" =~ \.(mp4|mkv|mov|webm)$ ]]; then
    sed -i '/^\s*exec-once\s*=\s*swww-daemon\s*--format\s*xrgb\s*$/s/^/\#/' "$startup_config"
    sed -i '/^\s*#\s*exec-once\s*=\s*mpvpaper\s*.*$/s/^#\s*//;' "$startup_config"
    local config_path="${selected_file/#$HOME/\$HOME}"
    sed -i "s|^\$livewallpaper=.*|\$livewallpaper=\"$config_path\"|" "$startup_config"
  else
    sed -i '/^\s*#\s*exec-once\s*=\s*swww-daemon\s*--format\s*xrgb\s*$/s/^\s*#\s*//;' "$startup_config"
    sed -i '/^\s*exec-once\s*=\s*mpvpaper\s*.*$/s/^/\#/' "$startup_config"
  fi
}

apply_image_wallpaper() {
  kill_wallpaper_for_image
  pgrep -x "swww-daemon" >/dev/null || swww-daemon --format xrgb &
  swww img -o "$focused_monitor" "$1" $SWWW_PARAMS
  "$SCRIPTSDIR/WallustSwww.sh" "$1"
  sleep 2
  "$SCRIPTSDIR/Refresh.sh"
}

apply_video_wallpaper() {
  kill_wallpaper_for_video
  mpvpaper '*' -o "load-scripts=no no-audio --loop" "$1" &
}

main() {
  choice=$(menu | $rofi_command)
  [[ -z "$choice" ]] && exit 0

  # --- UPDATED REGEX: Matches 1 through 12 ---
  if [[ "$choice" =~ ^([0-9]+)\.\ Random$ ]]; then
    idx=$(( ${BASH_REMATCH[1]} - 1 ))
    selected_file="${RANDOM_WALLS[$idx]}"
  else
    choice_clean=$(echo "$choice" | xargs)
    selected_file=$(find "$wallDIR" -maxdepth 2 -name "$choice_clean" -print -quit)
  fi

  if [[ ! -f "$selected_file" ]]; then
    notify-send -i "$iDIR/error.png" "Error" "Wallpaper file not found."
    exit 1
  fi

  modify_startup_config "$selected_file"
  if [[ "$selected_file" =~ \.(mp4|mkv|mov|webm|MP4|MKV|MOV|WEBM)$ ]]; then
    apply_video_wallpaper "$selected_file"
  else
    apply_image_wallpaper "$selected_file"
  fi
}

pkill rofi 2>/dev/null
main
