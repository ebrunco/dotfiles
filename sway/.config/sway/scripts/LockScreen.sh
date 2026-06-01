#!/usr/bin/env bash
bash "$HOME/.config/sway/scripts/WeatherWrap.sh" >/dev/null 2>&1 &
swaylock --config "$HOME/.config/sway/swaylock.conf"
