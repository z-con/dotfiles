#!/usr/bin/env python3
import evdev
import subprocess
import time

DEVICE_PATH = '/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-mouse'
DEBOUNCE = 0.15  # seconds between window switches


def cycle(forward):
    subprocess.run(['hypr-cycle-nowrap', 'next' if forward else 'prev'])


device = evdev.InputDevice(DEVICE_PATH)
last = 0

for event in device.read_loop():
    if event.type != evdev.ecodes.EV_REL or event.code != evdev.ecodes.REL_HWHEEL:
        continue
    now = time.monotonic()
    if now - last < DEBOUNCE:
        continue
    last = now
    cycle(event.value > 0)
