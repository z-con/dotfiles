#!/bin/bash

MONITOR="eDP-1"
# Keep Y position fixed at 480 (matches monitors.conf landscape value) for all
# orientations. Changing Y during rotation causes Hyprland to not update the
# workspace base position atomically, producing a large black gap at the top.
POS="0x480"

monitor-sensor 2>&1 | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS,1,transform,0" ;;
        *"Accelerometer orientation changed: right-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS,1,transform,3" ;;
        *"Accelerometer orientation changed: bottom-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS,1,transform,2" ;;
        *"Accelerometer orientation changed: left-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS,1,transform,1" ;;
    esac
done
