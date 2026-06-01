#!/usr/bin/env bash
# Drop-down terminal using Sway marks + scratchpad
# Usage: Dropterminal.sh [terminal_command]

TERMINAL_CMD="${1:-kitty}"
MARK="dropdown-term"

if swaymsg -t get_tree | jq -e ".. | select(.marks? | arrays | contains([\"$MARK\"]))" >/dev/null 2>&1; then
    swaymsg "[con_mark=$MARK] scratchpad show"
else
    swaymsg "exec $TERMINAL_CMD --app-id dropdown-term"
    sleep 0.3
    swaymsg "[app_id=dropdown-term] mark $MARK; \
             [con_mark=$MARK] floating enable; \
             [con_mark=$MARK] resize set 65 ppt 65 ppt; \
             [con_mark=$MARK] move position center; \
             [con_mark=$MARK] move scratchpad; \
             [con_mark=$MARK] scratchpad show"
fi
