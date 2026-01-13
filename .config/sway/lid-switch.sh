#!/usr/bin/env bash

# Detect external (non-eDP) active monitors
EXTERNAL=$(swaymsg -t get_outputs \
    | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name')

if [ -n "$EXTERNAL" ]; then
    if [ "$1" = "off" ]; then
        notify-send "Sway output" "internal display disabled"
        swaymsg output eDP-1 disable
    elif [ "$1" = "on" ]; then
        notify-send "Sway output" "internal display enabled"
        swaymsg output eDP-1 enable
    fi
fi

