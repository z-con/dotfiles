#!/bin/bash
# When an external monitor is connected, move workspaces 6-10 to it.
# When it's disconnected, Hyprland automatically moves those workspaces back to eDP-1.

LOG=/tmp/ext-monitor-workspaces.log
MIGRATION_FLAG=/tmp/workspace-migration-restarting-waybar

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

move_workspaces() {
  local MONITOR="$1"
  log "move_workspaces called for: '$MONITOR'"
  sleep 1

  local PREV_WS
  PREV_WS=$(hyprctl activeworkspace -j | jq '.id')
  log "PREV_WS=$PREV_WS"

  for ws in 6 7 8 9 10; do
    RESULT=$(hyprctl dispatch moveworkspacetomonitor "$ws $MONITOR" 2>&1)
    log "moveworkspacetomonitor $ws $MONITOR -> $RESULT"
  done

  sleep 0.5
  log "dispatching workspace 6"
  hyprctl dispatch workspace 6
  hyprctl dispatch workspace "$PREV_WS"

  # Pin workspaces 6-10 to this monitor in Hyprland's rules so waybar reads the correct assignment.
  # These rules are not in hyprland.conf to avoid them showing as unassigned persistent on eDP-1.
  for ws in 6 7 8 9 10; do
    hyprctl keyword workspace "$ws, monitor:$MONITOR, persistent:true" >/dev/null
  done
  log "pinned workspaces 6-10 to $MONITOR via keyword"

  # Restart waybar so it initializes with the correct workspace assignments
  touch "$MIGRATION_FLAG"
  log "restarting waybar post-migration"
  omarchy-restart-app waybar
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

get_external_monitor() {
  hyprctl monitors -j | jq -r '.[].name' | grep -v "eDP-1" | head -1
}

# Re-migrate workspaces whenever waybar restarts (waybar restart doesn't fire monitoradded).
# Uses PID tracking instead of die/come-back polling to catch fast restarts.
watch_waybar_restarts() {
  local LAST_PID=""
  while true; do
    CURRENT_PID=$(pgrep -x waybar | head -1)
    if [ -n "$CURRENT_PID" ] && [ -n "$LAST_PID" ] && [ "$CURRENT_PID" != "$LAST_PID" ]; then
      sleep 1.5  # Let waybar fully initialize
      if [ -f "$MIGRATION_FLAG" ]; then
        rm -f "$MIGRATION_FLAG"
        log "waybar restart triggered by migration, skipping re-migration"
      else
        EXTERNAL=$(get_external_monitor)
        if [ -n "$EXTERNAL" ]; then
          log "waybar restarted by user, re-migrating workspaces to $EXTERNAL"
          move_workspaces "$EXTERNAL"
        fi
      fi
    fi
    [ -n "$CURRENT_PID" ] && LAST_PID="$CURRENT_PID"
    sleep 1
  done
}

watch_waybar_restarts &

# Handle monitors already connected at startup (monitoradded fires before socat is ready)
sleep 2
EXISTING_MONITOR=$(get_external_monitor)
if [ -n "$EXISTING_MONITOR" ]; then
  move_workspaces "$EXISTING_MONITOR"
fi

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
  | while read -r line; do handle "$line"; done
