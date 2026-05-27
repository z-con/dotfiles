#!/bin/bash

MONITOR="eDP-1"
# Explicit positions to prevent Hyprland auto-placement from reordering monitors.
# Landscape: 1920x1200 centered alongside DP-3 (2160 tall) → Y=(2160-1200)/2=480
# Portrait:  1200x1920 centered alongside DP-3 (2160 tall) → Y=(2160-1920)/2=120
POS_LANDSCAPE="0x480"
POS_PORTRAIT="0x120"

monitor-sensor 2>&1 | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS_LANDSCAPE,1,transform,0" ;;
        *"Accelerometer orientation changed: right-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS_PORTRAIT,1,transform,3" ;;
        *"Accelerometer orientation changed: bottom-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS_LANDSCAPE,1,transform,2" ;;
        *"Accelerometer orientation changed: left-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,$POS_PORTRAIT,1,transform,1" ;;
    esac
done
