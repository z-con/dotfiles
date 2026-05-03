#!/bin/bash
# Resize tiled windows in dwindle layout.
# Arrow keys move the shared divider; neither window in a pair may drop below
# 25% of the pair's combined width (or height).

DIRECTION="$1"
AMOUNT=50

# Prevent concurrent executions — rapid key repeat can cause limit overshooting
exec 9>/tmp/resize-scroll.lock
flock -n 9 || exit 0

WIN_JSON=$(hyprctl activewindow -j)
WIN_X=$(echo "$WIN_JSON" | jq '.at[0]')
WIN_Y=$(echo "$WIN_JSON" | jq '.at[1]')
WIN_W=$(echo "$WIN_JSON" | jq '.size[0]')
WIN_H=$(echo "$WIN_JSON" | jq '.size[1]')
WS_ID=$(echo "$WIN_JSON" | jq '.workspace.id')

WINS=$(hyprctl clients -j | jq --argjson ws "$WS_ID" \
  '[.[] | select(.workspace.id == $ws and .floating == false)]')

# Find the size of the neighboring window in the given direction.
# Uses a 20px tolerance to bridge borders and gaps.
neighbor_w() {
  case "$1" in
    left)
      echo "$WINS" | jq --argjson x "$WIN_X" \
        '[.[] | select((.at[0] + .size[0]) >= ($x - 20) and (.at[0] + .size[0]) <= ($x + 20))]
         | if length > 0 then .[0].size[0] else empty end'
      ;;
    right)
      echo "$WINS" | jq --argjson rx "$((WIN_X + WIN_W))" \
        '[.[] | select(.at[0] >= ($rx - 20) and .at[0] <= ($rx + 20))]
         | if length > 0 then .[0].size[0] else empty end'
      ;;
  esac
}

neighbor_h() {
  case "$1" in
    up)
      echo "$WINS" | jq --argjson y "$WIN_Y" \
        '[.[] | select((.at[1] + .size[1]) >= ($y - 20) and (.at[1] + .size[1]) <= ($y + 20))]
         | if length > 0 then .[0].size[1] else empty end'
      ;;
    down)
      echo "$WINS" | jq --argjson by "$((WIN_Y + WIN_H))" \
        '[.[] | select(.at[1] >= ($by - 20) and .at[1] <= ($by + 20))]
         | if length > 0 then .[0].size[1] else empty end'
      ;;
  esac
}

# Dispatch resize only if the window that will shrink stays >= 25% of the pair.
# shrink_size: current size of the window about to shrink
# other_size:  current size of its pair partner (empty = no neighbor, allow freely)
check_and_resize() {
  local shrink_size="$1" other_size="$2" dispatch="$3"
  if [ -z "$other_size" ]; then
    hyprctl dispatch $dispatch
    return
  fi
  local combined=$((shrink_size + other_size))
  [ $((shrink_size - AMOUNT)) -ge $((combined / 4)) ] && hyprctl dispatch $dispatch
}

# In dwindle, resizeactive always moves the shared divider edge:
#   left/right: horizontal divider moves left/right
#   up/down:    vertical divider moves up/down
# The window on the "near" side of that edge shrinks; the other grows.
# We enforce 25% of the pair on the shrinking window only.

case "$DIRECTION" in
  left)
    # Divider moves left → left window shrinks
    LW=$(neighbor_w left)
    if [ -n "$LW" ]; then
      # Active is the right window; left neighbor shrinks
      check_and_resize "$LW" "$WIN_W" "resizeactive -${AMOUNT} 0"
    else
      # Active is the left window; it shrinks itself
      check_and_resize "$WIN_W" "$(neighbor_w right)" "resizeactive -${AMOUNT} 0"
    fi
    ;;
  right)
    # Divider moves right → right window shrinks
    RW=$(neighbor_w right)
    if [ -n "$RW" ]; then
      # Active is the left window; right neighbor shrinks
      check_and_resize "$RW" "$WIN_W" "resizeactive ${AMOUNT} 0"
    else
      # Active is the right window; it shrinks itself
      check_and_resize "$WIN_W" "$(neighbor_w left)" "resizeactive ${AMOUNT} 0"
    fi
    ;;
  up)
    # Divider moves up → top window shrinks
    TH=$(neighbor_h up)
    if [ -n "$TH" ]; then
      # Active is the bottom window; top neighbor shrinks
      check_and_resize "$TH" "$WIN_H" "resizeactive 0 -${AMOUNT}"
    else
      # Active is the top window; it shrinks itself
      check_and_resize "$WIN_H" "$(neighbor_h down)" "resizeactive 0 -${AMOUNT}"
    fi
    ;;
  down)
    # Divider moves down → bottom window shrinks
    BH=$(neighbor_h down)
    if [ -n "$BH" ]; then
      # Active is the top window; bottom neighbor shrinks
      check_and_resize "$BH" "$WIN_H" "resizeactive 0 ${AMOUNT}"
    else
      # Active is the bottom window; it shrinks itself
      check_and_resize "$WIN_H" "$(neighbor_h up)" "resizeactive 0 ${AMOUNT}"
    fi
    ;;
esac
