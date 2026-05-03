#!/bin/bash
# Resize windows in scrolling layout while keeping the screen-edge-adjacent side fixed.
# When two windows are visible, CTRL+LEFT/RIGHT always moves the shared divider,
# regardless of which window is focused.
# Falls back to standard resizeactive behavior in dwindle/other layouts.
# Limit: neither window may drop below 25% of the two windows' combined width (or height).

DIRECTION="$1"
AMOUNT=50

# Prevent concurrent executions — rapid key repeat can cause limit overshooting
exec 9>/tmp/resize-scroll.lock
flock -n 9 || exit 0

LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

MON_JSON=$(hyprctl monitors -j | jq '.[] | select(.focused == true)')
MON_X=$(echo "$MON_JSON" | jq '.x')
MON_W=$(echo "$MON_JSON" | jq '(.width / .scale) | floor')
MON_H=$(echo "$MON_JSON" | jq '(.height / .scale) | floor')

# Fallback bounds for non-scrolling layout or single-window cases (1/4 of screen)
MIN_W=$((MON_W / 4))
MAX_W=$((MON_W * 3 / 4))
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

# Move the divider between two windows: neither may drop below 25% of their combined size.
# The focused window must already be the left window. left_w and right_w are their current widths.
resize_two_windows() {
  local dir="$1" left_w="$2" right_w="$3"
  local min_each=$(( (left_w + right_w) / 4 ))

  echo "[$(date +%T.%N)] dir=$dir left=$left_w right=$right_w min=$min_each" >> /tmp/resize-debug.log

  case "$dir" in
    left)
      if [ $((left_w - AMOUNT)) -ge $min_each ]; then
        hyprctl dispatch resizeactive -${AMOUNT} 0
        echo "  → resized (left shrink)" >> /tmp/resize-debug.log
      else
        echo "  → BLOCKED (left would hit $((left_w - AMOUNT)) < $min_each)" >> /tmp/resize-debug.log
      fi
      ;;
    right)
      if [ $((right_w - AMOUNT)) -ge $min_each ]; then
        hyprctl dispatch resizeactive ${AMOUNT} 0
        echo "  → resized (right shrink)" >> /tmp/resize-debug.log
      else
        echo "  → BLOCKED (right would hit $((right_w - AMOUNT)) < $min_each)" >> /tmp/resize-debug.log
      fi
      ;;
  esac

  # Log actual sizes after resize
  local after
  after=$(hyprctl clients -j | jq --argjson ws "$WS_ID" \
    '[.[] | select(.workspace.id == $ws and .floating == false)] | sort_by(.at[0]) | map(.size[0])')
  echo "  → actual widths after: $after" >> /tmp/resize-debug.log
}

echo "[$(date +%T.%N)] START dir=$DIRECTION layout=$LAYOUT" >> /tmp/resize-debug.log

if [ "$LAYOUT" != "scrolling" ]; then
  echo "  → non-scrolling fallback" >> /tmp/resize-debug.log
  resize_with_limits "$DIRECTION"
  exit 0
fi

# Vertical resizing in scrolling layout: windows are side-by-side so there is no shared
# horizontal divider — just resize the active window against the screen-height bound.
if [ "$DIRECTION" = "up" ] || [ "$DIRECTION" = "down" ]; then
  resize_with_limits "$DIRECTION"
  exit 0
fi

WINDOW_JSON=$(hyprctl activewindow -j)
WIN_X=$(echo "$WINDOW_JSON" | jq '.at[0]')
WIN_W=$(echo "$WINDOW_JSON" | jq '.size[0]')
WIN_ADDR=$(echo "$WINDOW_JSON" | jq -r '.address')
WS_ID=$(echo "$WINDOW_JSON" | jq '.workspace.id')

WIN_REL_X=$((WIN_X - MON_X))

if [ "$WIN_REL_X" -le 20 ]; then
  # On the left/only window — find right neighbor's width without changing focus
  RIGHT_W=$(hyprctl clients -j | jq --argjson ws "$WS_ID" --argjson lx "$WIN_X" \
    '[.[] | select(.workspace.id == $ws and .floating == false and .at[0] > $lx)]
     | sort_by(.at[0])
     | if length > 0 then .[0].size[0] else empty end')

  if [ -z "$RIGHT_W" ]; then
    resize_with_limits "$DIRECTION"
  else
    resize_two_windows "$DIRECTION" "$WIN_W" "$RIGHT_W"
  fi
else
  # On the right window — control the divider by resizing the left neighbor
  hyprctl dispatch movefocus l
  LEFT_ADDR=$(hyprctl activewindow -j | jq -r '.address')

  if [ "$LEFT_ADDR" != "$WIN_ADDR" ]; then
    # WIN_W (captured before focus switch) is the right window's current width
    LEFT_W=$(hyprctl activewindow -j | jq '.size[0]')
    resize_two_windows "$DIRECTION" "$LEFT_W" "$WIN_W"
    hyprctl dispatch focuswindow "address:${WIN_ADDR}"
  else
    # No left neighbor (shouldn't happen), fall back to direct resize
    resize_with_limits "$DIRECTION"
  fi
fi
