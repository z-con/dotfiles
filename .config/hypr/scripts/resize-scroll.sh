#!/bin/bash
# Move the divider between two windows in scrolling layout.
# Resizes both windows symmetrically so outer edges stay anchored to the screen.
# Falls back to standard resizeactive in dwindle/other layouts.

DIRECTION="$1"
AMOUNT=50

LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

if [ "$LAYOUT" != "scrolling" ]; then
  case "$DIRECTION" in
    left)  hyprctl dispatch resizeactive -${AMOUNT} 0 ;;
    right) hyprctl dispatch resizeactive ${AMOUNT} 0 ;;
    up)    hyprctl dispatch resizeactive 0 -${AMOUNT} ;;
    down)  hyprctl dispatch resizeactive 0 ${AMOUNT} ;;
  esac
  exit 0
fi

WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')
ORIG_ADDR=$(hyprctl activewindow -j | jq -r '.address')

# Get the two leftmost non-floating windows on this workspace, sorted by X
WINDOWS=$(hyprctl clients -j | jq --argjson ws "$WORKSPACE" \
  '[.[] | select(.workspace.id == $ws and .floating == false)] | sort_by(.at[0])')
WIN_COUNT=$(echo "$WINDOWS" | jq 'length')

if [ "$WIN_COUNT" -lt 2 ]; then
  # Single window — standard resize
  case "$DIRECTION" in
    left)  hyprctl dispatch resizeactive -${AMOUNT} 0 ;;
    right) hyprctl dispatch resizeactive ${AMOUNT} 0 ;;
    up)    hyprctl dispatch resizeactive 0 -${AMOUNT} ;;
    down)  hyprctl dispatch resizeactive 0 ${AMOUNT} ;;
  esac
  exit 0
fi

LEFT_ADDR=$(echo "$WINDOWS" | jq -r '.[0].address')
RIGHT_ADDR=$(echo "$WINDOWS" | jq -r '.[1].address')

# Move divider by growing one side and shrinking the other by the same amount,
# then restore focus. Using --batch keeps it atomic (no flicker between frames).
case "$DIRECTION" in
  right)
    hyprctl --batch "dispatch focuswindow address:${LEFT_ADDR}; \
      dispatch resizeactive ${AMOUNT} 0; \
      dispatch focuswindow address:${RIGHT_ADDR}; \
      dispatch resizeactive -${AMOUNT} 0; \
      dispatch focuswindow address:${ORIG_ADDR}"
    ;;
  left)
    hyprctl --batch "dispatch focuswindow address:${LEFT_ADDR}; \
      dispatch resizeactive -${AMOUNT} 0; \
      dispatch focuswindow address:${RIGHT_ADDR}; \
      dispatch resizeactive ${AMOUNT} 0; \
      dispatch focuswindow address:${ORIG_ADDR}"
    ;;
  up)   hyprctl dispatch resizeactive 0 -${AMOUNT} ;;
  down) hyprctl dispatch resizeactive 0 ${AMOUNT} ;;
esac
