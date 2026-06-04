#!/bin/bash
# Place workspaces based on connected monitors:
#   Desktop (no eDP-1):          all workspaces on primary, no moves needed
#   Laptop only (eDP-1, no ext): all workspaces on eDP-1, no moves needed
#   Laptop + external:           1-5 on eDP-1, 6-10 on external monitor

LOG=/tmp/ext-monitor-workspaces.log

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

has_edp() {
  hyprctl monitors -j | jq -e '.[] | select(.name == "eDP-1")' > /dev/null 2>&1
}

assign_workspaces() {
  local EXTERNAL="$1"
  log "assign_workspaces: external='$EXTERNAL'"
  sleep 1

  local PREV_WS
  PREV_WS=$(hyprctl activeworkspace -j | jq '.id')

  if has_edp; then
    log "Laptop + external: 1-5 -> eDP-1, 6-10 -> $EXTERNAL"
    for ws in 1 2 3 4 5; do
      RESULT=$(hyprctl dispatch moveworkspacetomonitor "$ws eDP-1" 2>&1)
      log "moveworkspacetomonitor $ws eDP-1 -> $RESULT"
    done
    for ws in 6 7 8 9 10; do
      RESULT=$(hyprctl dispatch moveworkspacetomonitor "$ws $EXTERNAL" 2>&1)
      log "moveworkspacetomonitor $ws $EXTERNAL -> $RESULT"
    done
    sleep 0.5
    hyprctl dispatch workspace 6
  else
    log "Desktop: no eDP-1, no moves needed"
  fi

  hyprctl dispatch workspace "$PREV_WS"
}

handle() {
  if echo "$1" | grep -q "^monitoradded>>"; then
    MONITOR=${1#monitoradded>>}
    log "monitoradded event: '$MONITOR'"
    if [ "$MONITOR" != "eDP-1" ]; then
      assign_workspaces "$MONITOR"
    fi
  fi
}

# Handle monitors already connected at startup
sleep 2
EXISTING_EXTERNAL=$(hyprctl monitors -j | jq -r '.[].name' | grep -v "eDP-1" | head -1)
if [ -n "$EXISTING_EXTERNAL" ]; then
  assign_workspaces "$EXISTING_EXTERNAL"
else
  log "Startup: single monitor, no workspace moves needed"
fi

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
  | while read -r line; do handle "$line"; done
