# dotfiles

Zach's personal configuration files for an [Omarchy](https://omarchy.com)-based Linux desktop.

## What's included

| Config | Path |
|---|---|
| Hyprland | `.config/hypr/` |
| Waybar | `.config/waybar/` |
| Mako (notifications) | `.config/mako/` |
| Walker (app launcher) | `.config/walker/` |
| Ghostty, Kitty, Alacritty | `.config/ghostty/`, `.config/kitty/`, `.config/alacritty/` |
| Fish shell | `.config/fish/` |
| Starship prompt | `.config/starship.toml` |
| tmux | `.config/tmux/` |
| btop, fastfetch, lazygit | `.config/btop/`, `.config/fastfetch/`, `.config/lazygit/` |
| Omarchy themes & wallpapers | `.config/omarchy/` |

Themes included: **aetheria**, **city-783**, **event-horizon**, **zachs-theme**

## Fresh install

### 1. Install Omarchy

Follow the [Omarchy installation guide](https://omarchy.com). Omarchy sets up Hyprland, Waybar, and all supporting tools.

### 2. Clone this repo

```bash
git clone https://github.com/z-con/dotfiles.git ~/dotfiles
```

### 3. Run the installer

```bash
bash ~/dotfiles/install.sh
```

The script copies all configs into `~/.config/`, reloads Hyprland and Waybar if a live session is detected, and prints a summary of what it applied. It's safe to re-run at any time.

### 4. Apply a theme

```bash
omarchy-theme zachs-theme
```

Or pick one interactively via the Omarchy menu (`Super + Space` → System → Theme).

## Updating an existing install

Pull the latest changes and re-run the installer:

```bash
cd ~/dotfiles && git pull && bash install.sh
```

## How auto-sync works

On the machine that owns this repo, a Claude Code Stop hook runs `sync.sh` at the end of every session where config files were edited. It rsyncs all tracked paths into `~/dotfiles/`, commits any changes, and pushes to GitHub — so the repo always reflects the current state of the system without any manual steps.

To set this up on a new machine after cloning, add the hook to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/dotfiles/sync.sh",
            "timeout": 30,
            "async": true
          }
        ]
      }
    ]
  }
}
```
