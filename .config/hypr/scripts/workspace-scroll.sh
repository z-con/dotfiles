#!/bin/bash
# Scroll workspaces within per-monitor bounds without wrapping or creating new ones.
# Usage: workspace-scroll.sh <next|prev>

DIRECTION=$1
CURRENT=$(hyprctl activeworkspace -j | jq '.id')
MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')

if [[ "$MONITOR" == "eDP-1" ]]; then
    MIN=1; MAX=5
else
    MIN=6; MAX=10
fi

if [[ "$DIRECTION" == "next" && $CURRENT -lt $MAX ]]; then
    hyprctl dispatch workspace $((CURRENT + 1))
elif [[ "$DIRECTION" == "prev" && $CURRENT -gt $MIN ]]; then
    hyprctl dispatch workspace $((CURRENT - 1))
fi
