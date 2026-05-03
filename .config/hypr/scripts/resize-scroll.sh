#!/bin/bash
# Resize windows in scrolling layout while keeping the screen-edge-adjacent side fixed.
# When two windows are visible, CTRL+LEFT/RIGHT always moves the shared divider,
# regardless of which window is focused.
# Falls back to standard resizeactive behavior in dwindle/other layouts.
# Limits: partition stays within 1/5 of screen width from each side,
#         and 1/4 of screen height from top/bottom.

DIRECTION="$1"
AMOUNT=50

LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

MON_JSON=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MON_X=$(echo "$MON_JSON" | jq '.x')
MON_W=$(echo "$MON_JSON" | jq '(.width / .scale) | floor')
MON_H=$(echo "$MON_JSON" | jq '(.height / .scale) | floor')

MIN_W=$((MON_W / 5))
MAX_W=$((MON_W * 4 / 5))
MIN_H=$((MON_H / 4))
MAX_H=$((MON_H * 3 / 4))

resize_with_limits() {
  local win_json win_w win_h
  win_json=$(hyprctl activewindow -j)
  win_w=$(echo "$win_json" | jq '.size[0]')
  win_h=$(echo "$win_json" | jq '.size[1]')

  case "$1" in
    left)  [ $((win_w - AMOUNT)) -ge $MIN_W ] && hyprctl dispatch resizeactive -${AMOUNT} 0 ;;
    right) [ $((win_w + AMOUNT)) -le $MAX_W ] && hyprctl dispatch resizeactive ${AMOUNT} 0 ;;
    up)    [ $((win_h - AMOUNT)) -ge $MIN_H ] && hyprctl dispatch resizeactive 0 -${AMOUNT} ;;
    down)  [ $((win_h + AMOUNT)) -le $MAX_H ] && hyprctl dispatch resizeactive 0 ${AMOUNT} ;;
  esac
}

if [ "$LAYOUT" != "scrolling" ]; then
  resize_with_limits "$DIRECTION"
  exit 0
fi

WINDOW_JSON=$(hyprctl activewindow -j)
WIN_X=$(echo "$WINDOW_JSON" | jq '.at[0]')
WIN_ADDR=$(echo "$WINDOW_JSON" | jq -r '.address')

WIN_REL_X=$((WIN_X - MON_X))

if [ "$WIN_REL_X" -le 20 ]; then
  # Already on the left/only window — the divider is this window's right edge
  resize_with_limits "$DIRECTION"
else
  # On the right window — control the divider by resizing the left neighbor
  hyprctl dispatch movefocus l
  LEFT_ADDR=$(hyprctl activewindow -j | jq -r '.address')

  if [ "$LEFT_ADDR" != "$WIN_ADDR" ]; then
    resize_with_limits "$DIRECTION"
    hyprctl dispatch focuswindow "address:${WIN_ADDR}"
  else
    # No left neighbor (shouldn't happen), fall back to direct resize
    resize_with_limits "$DIRECTION"
  fi
fi
