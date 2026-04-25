#!/bin/bash
# When an external monitor is connected, move workspaces 6-10 to it.
# When it's disconnected, Hyprland automatically moves those workspaces back to eDP-1.

handle() {
  if echo "$1" | grep -q "^monitoradded>>"; then
    MONITOR=${1#monitoradded>>}
    if [ "$MONITOR" != "eDP-1" ]; then
      sleep 1  # give Hyprland a moment to initialize the monitor
      for ws in 6 7 8 9 10; do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$MONITOR"
      done
    fi
  fi
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
  | while read -r line; do handle "$line"; done
