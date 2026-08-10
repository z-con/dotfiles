#!/bin/bash

MONITOR="eDP-1"
# Keep Y position fixed at 480 (matches monitors.conf landscape value) for all
# orientations. Changing Y during rotation causes Hyprland to not update the
# workspace base position atomically, producing a large black gap at the top.
POS="0x480"

TABLET="wacom-hid-5276-pen"

rotate() {
    hyprctl keyword monitor "$MONITOR,preferred,$POS,1,transform,$1"
    hyprctl keyword "device[$TABLET]:transform" "$1"
}

monitor-sensor 2>&1 | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)    rotate 0 ;;
        *"Accelerometer orientation changed: right-up"*)  rotate 3 ;;
        *"Accelerometer orientation changed: bottom-up"*) rotate 2 ;;
        *"Accelerometer orientation changed: left-up"*)   rotate 1 ;;
    esac
done
