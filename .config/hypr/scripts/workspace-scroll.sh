#!/bin/bash
# Scroll workspaces within per-monitor bounds without wrapping or creating new ones.
# Usage: workspace-scroll.sh <next|prev>

DIRECTION=$1
CURRENT=$(hyprctl activeworkspace -j | jq '.id')
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

WORKSPACES=$(hyprctl workspaces -j | jq "[.[] | select(.monitor == \"$MONITOR\") | .id] | sort")
MIN=$(echo "$WORKSPACES" | jq '.[0]')
MAX=$(echo "$WORKSPACES" | jq '.[-1]')

if [[ "$DIRECTION" == "next" && $CURRENT -lt $MAX ]]; then
    hyprctl dispatch workspace $((CURRENT + 1))
elif [[ "$DIRECTION" == "prev" && $CURRENT -gt $MIN ]]; then
    hyprctl dispatch workspace $((CURRENT - 1))
fi
