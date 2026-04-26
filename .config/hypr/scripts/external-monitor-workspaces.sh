#!/bin/bash
# When an external monitor is connected, move workspaces 6-10 to it.
# When it's disconnected, Hyprland automatically moves those workspaces back to eDP-1.

LOG=/tmp/ext-monitor-workspaces.log

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

move_workspaces() {
  local MONITOR="$1"
  log "move_workspaces called for: '$MONITOR'"
  sleep 1

  local PREV_WS
  PREV_WS=$(hyprctl activeworkspace -j | jq '.id')
  log "PREV_WS=$PREV_WS"

  for ws in 5 6 7 8; do
    RESULT=$(hyprctl dispatch moveworkspacetomonitor "$ws $MONITOR" 2>&1)
    log "moveworkspacetomonitor $ws $MONITOR -> $RESULT"
  done

  sleep 0.5
  log "dispatching workspace 5"
  hyprctl dispatch workspace 5
  hyprctl dispatch workspace "$PREV_WS"
}

handle() {
  if echo "$1" | grep -q "^monitoradded>>"; then
    MONITOR=${1#monitoradded>>}
    log "monitoradded event: '$MONITOR'"
    if [ "$MONITOR" != "eDP-1" ]; then
      move_workspaces "$MONITOR"
    fi
  fi
}

# Handle monitors already connected at startup (monitoradded fires before socat is ready)
sleep 2
EXISTING_MONITOR=$(hyprctl monitors -j | jq -r '.[].name' | grep -v "eDP-1" | head -1)
if [ -n "$EXISTING_MONITOR" ]; then
  move_workspaces "$EXISTING_MONITOR"
fi

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
  | while read -r line; do handle "$line"; done
