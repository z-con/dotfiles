-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

hl.env("GDK_SCALE", "1")

hl.monitor({ output = "eDP-1", mode = "2160x1350@60", position = "0x405", scale = 1 })
hl.monitor({ output = "DP-3", mode = "3840x2160@60", position = "2160x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })
