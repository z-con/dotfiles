#!/bin/bash

MONITOR="eDP-1"

monitor-sensor 2>&1 | while IFS= read -r line; do
    case "$line" in
        *"Accelerometer orientation changed: normal"*)
            hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,0" ;;
        *"Accelerometer orientation changed: right-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,3" ;;
        *"Accelerometer orientation changed: bottom-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,2" ;;
        *"Accelerometer orientation changed: left-up"*)
            hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,1" ;;
    esac
done
