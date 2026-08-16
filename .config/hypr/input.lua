-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Repeat rate, numlock, and touchpad scroll factor already match Omarchy's
-- quattro defaults, so they don't need to be repeated here.

-- Wacom pen on the X1 Nano.
hl.device({ name = "wacom-hid-5276-pen", output = "eDP-1", transform = 0 })

-- Three-finger swipe up/down to open/close the workspace overview.
hl.gesture({
  fingers = 3,
  direction = "up",
  action = function() hl.exec_cmd("qs --path ~/.config/quickshell/hypr-overview ipc call overview open") end,
})
hl.gesture({
  fingers = 3,
  direction = "down",
  action = function() hl.exec_cmd("qs --path ~/.config/quickshell/hypr-overview ipc call overview close") end,
})

-- Three-finger swipe left/right to move between workspaces.
hl.gesture({
  fingers = 3,
  direction = "left",
  action = function() hl.exec_cmd("~/.config/hypr/scripts/workspace-scroll.sh prev") end,
})
hl.gesture({
  fingers = 3,
  direction = "right",
  action = function() hl.exec_cmd("~/.config/hypr/scripts/workspace-scroll.sh next") end,
})
