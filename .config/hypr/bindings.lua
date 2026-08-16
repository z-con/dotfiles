-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Claude Code (default binds SUPER+CTRL+RETURN to Herdr)
hl.unbind("SUPER + CTRL + RETURN")
o.bind("SUPER + CTRL + RETURN", "Claude Code", "uwsm-app -- ghostty --working-directory=/home/zach/Claude -e claude")

-- Typora (default binds SUPER+SHIFT+W to Omawrite)
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", "uwsm-app -- typora --enable-wayland-ime")

-- Resize tiled windows with Super + Ctrl + arrow keys
-- In scrolling layout: always moves the shared divider, keeping the screen-edge side fixed
-- In dwindle layout: standard resizeactive behavior
o.bind("SUPER + CTRL + left", "Move divider left", "~/.config/hypr/scripts/resize-scroll.sh left", { repeating = true })
o.bind("SUPER + CTRL + right", "Move divider right", "~/.config/hypr/scripts/resize-scroll.sh right", { repeating = true })
o.bind("SUPER + CTRL + up", "Resize window up", "~/.config/hypr/scripts/resize-scroll.sh up", { repeating = true })
o.bind("SUPER + CTRL + down", "Resize window down", "~/.config/hypr/scripts/resize-scroll.sh down", { repeating = true })

hl.unbind("SUPER + L")

-- Close all open windows
o.bind("SUPER + ALT + W", "Close all windows", "omarchy-hyprland-window-close-all")

-- Overwrite existing binding, putting the app launcher on Super + Space
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Launch apps", "omarchy-launch-walker --width 300 --minheight 1 --maxheight 630")

-- Logitech MX Master thumb buttons - workspace switching
o.bind("mouse:275", "Previous workspace", "~/.config/hypr/scripts/workspace-scroll.sh prev")
o.bind("mouse:276", "Next workspace", "~/.config/hypr/scripts/workspace-scroll.sh next")
-- Bottom thumb button (gesture button) - workspace overview
o.bind("mouse:277", "Workspace overview", hl.dsp.global("quickshell:overviewToggle"))
