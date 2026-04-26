#!/bin/bash
# When an external monitor is connected, move workspaces 6-10 to it.
# When it's disconnected, Hyprland automatically moves those workspaces back to eDP-1.

move_workspaces() {
  local MONITOR="$1"
  sleep 1
  for ws in 6 7 8 9 10; do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$MONITOR"
  done
  # Hyprland creates a new workspace (e.g. 11) for the monitor before we can move 6-10 over.
  # Switch the external monitor to workspace 6 to get off that auto-created workspace.
  hyprctl dispatch focusmonitor "$MONITOR"
  hyprctl dispatch workspace 6
  hyprctl dispatch focusmonitor eDP-1
}

handle() {
  if echo "$1" | grep -q "^monitoradded>>"; then
    MONITOR=${1#monitoradded>>}
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
