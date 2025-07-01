#!/usr/bin/env zsh

set -eu
set -o pipefail

current_app=$(yabai -m query --windows | jq --raw-output '.[] | select(.["has-focus"] == true) | .app')

is_disabled() {
    yabai -m rule --list | jq --raw-output --exit-status ".[] | select(.app == \"$1\" and .manage == false)" > /dev/null

    return $?
}

get_rule_id() {
    echo $(yabai -m rule --list | jq --raw-output  ".[] | select(.app == \"$1\" and .manage == false) | .index")
}

if is_disabled "$current_app"; then
    rule_ids=$(get_rule_id "$current_app")

    for rule_id in $rule_ids; do
        yabai -m rule --remove "$rule_id"
    done

    yabai -m rule --apply app="$current_app" manage=on
else
    yabai -m rule --add app="$current_app" manage=off

    rule_id=$(get_rule_id "$current_app")
    yabai -m rule --apply "$rule_id"
fi
