#!/bin/bash
# Resize windows in scrolling layout while keeping the screen-edge-adjacent side fixed.
# When two windows are visible, CTRL+LEFT/RIGHT always moves the shared divider,
# regardless of which window is focused.
# Falls back to standard resizeactive behavior in dwindle/other layouts.

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

WINDOW_JSON=$(hyprctl activewindow -j)
WIN_X=$(echo "$WINDOW_JSON" | jq '.at[0]')
WIN_ADDR=$(echo "$WINDOW_JSON" | jq -r '.address')

# Get active monitor left edge (handles multi-monitor setups)
MON_X=$(hyprctl monitors -j | jq '.[] | select(.focused == true) | .x')
WIN_REL_X=$((WIN_X - MON_X))

resize_left_window() {
  case "$1" in
    left)  hyprctl dispatch resizeactive -${AMOUNT} 0 ;;
    right) hyprctl dispatch resizeactive ${AMOUNT} 0 ;;
    up)    hyprctl dispatch resizeactive 0 -${AMOUNT} ;;
    down)  hyprctl dispatch resizeactive 0 ${AMOUNT} ;;
  esac
}

if [ "$WIN_REL_X" -le 20 ]; then
  # Already on the left/only window — the divider is this window's right edge
  resize_left_window "$DIRECTION"
else
  # On the right window — control the divider by resizing the left neighbor
  hyprctl dispatch movefocus l
  LEFT_ADDR=$(hyprctl activewindow -j | jq -r '.address')

  if [ "$LEFT_ADDR" != "$WIN_ADDR" ]; then
    resize_left_window "$DIRECTION"
    hyprctl dispatch focuswindow "address:${WIN_ADDR}"
  else
    # No left neighbor (shouldn't happen), fall back to direct resize
    resize_left_window "$DIRECTION"
  fi
fi
