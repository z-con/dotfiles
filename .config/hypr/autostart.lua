-- Extra autostart processes.

-- Idle screensaver/lock-on-idle are handled natively by the Omarchy shell
-- (~/.config/omarchy/shell.json "idle"). hypridle is no longer installed in
-- quattro, so the old suspend-after-15-min and lock-before-sleep hooks are
-- gone too -- using quattro's built-in idle/lock defaults instead.

o.exec_on_start("hyprpm reload -n")
o.exec_on_start("omarchy-refresh-applications")
o.exec_on_start("nwg-dock-hyprland -p left -i 56 -nolauncher -a center -ml 4 -d -hl top -hd 0 -s style.css")
o.exec_on_start("~/.config/hypr/scripts/external-monitor-workspaces.sh")
o.exec_on_start("qs --path ~/.config/quickshell/hypr-overview")
