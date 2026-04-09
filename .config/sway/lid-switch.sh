#!/usr/bin/env bash

function notify() {
    local notify_cmd

    type notify-send    2>&1 > /dev/null && notify_cmd='notify-send'
    type notify-send.sh 2>&1 > /dev/null && notify_cmd='notify-send.sh'

    "$notify_cmd" "$1" "${2:-''}"
}

# Detect external (non-eDP) active monitors
EXTERNAL=$(swaymsg -t get_outputs \
    | jq -r '.[] | select(.name != "eDP-1" and .active == true) | .name')

if [ -n "$EXTERNAL" ]; then
    if [ "$1" = "off" ]; then
        notify "Sway output" "internal display disabled"
        swaymsg output eDP-1 disable
    elif [ "$1" = "on" ]; then
        notify "Sway output" "internal display enabled"
        swaymsg output eDP-1 enable
    fi
fi

