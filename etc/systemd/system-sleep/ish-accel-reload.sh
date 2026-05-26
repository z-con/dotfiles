#!/bin/bash
# Reload hid_sensor_accel_3d after resume — ISH gets stuck on this hardware
case "$1" in
    post)
        modprobe -r hid_sensor_accel_3d 2>/dev/null || true
        sleep 1
        modprobe hid_sensor_accel_3d
        ;;
esac
