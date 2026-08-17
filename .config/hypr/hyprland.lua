-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Prevent screensaver/idle when any window is fullscreen (e.g. video playback)
hl.window_rule({ match = { fullscreen = true }, idle_inhibit = "fullscreen" })

-- Pin workspaces to monitors
-- Laptop screen: workspaces 1-5
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1", persistent = true })
-- External monitor: workspaces 6-10 (assigned dynamically by external-monitor-workspaces.sh)
hl.workspace_rule({ workspace = "6", persistent = true })
hl.workspace_rule({ workspace = "7", persistent = true })
hl.workspace_rule({ workspace = "8", persistent = true })
hl.workspace_rule({ workspace = "9", persistent = true })
hl.workspace_rule({ workspace = "10", persistent = true })

-- Blur behind the app launcher and lighten its dim
hl.layer_rule({ match = { namespace = "walker" }, blur = true, ignore_alpha = 0.5 })

-- Give the coding agent terminal (org.omarchy.agent) a translucent, blurred
-- look -- quattro's global default opacity (0.985/0.96) is too subtle for
-- blur to read as anything.
o.window("org.omarchy.agent", { opacity = "0.85 0.75" })
