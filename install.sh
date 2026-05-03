#!/usr/bin/env bash
# Restores dotfiles from this repo to ~/.config/ on a fresh Omarchy install.
# Safe to re-run; uses rsync so only changed files are touched.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config"
LIVE=false
command -v hyprctl &>/dev/null && hyprctl monitors &>/dev/null 2>&1 && LIVE=true

info()    { echo "  $*"; }
success() { echo "✓ $*"; }
section() { echo; echo "── $* ──"; }

echo
echo "Zach's dotfiles installer"
echo "Repo: $DOTFILES → $CFG"
echo "Live Hyprland session: $LIVE"

# ── Prereqs ────────────────────────────────────────────────────────────────

section "Checking prerequisites"

for cmd in git rsync; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "✗ '$cmd' is required but not installed. Aborting." >&2
    exit 1
  fi
done
success "git, rsync present"

if [[ ! -d "$HOME/.local/share/omarchy" ]] && ! command -v omarchy &>/dev/null; then
  echo "  Warning: Omarchy doesn't appear to be installed."
  echo "  Install it first: https://omarchy.com"
  read -rp "  Continue anyway? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || exit 1
fi

# ── Apply configs ───────────────────────────────────────────────────────────

rsync_cfg() {
  local src="$DOTFILES/.config/$1" dst="$CFG/$1"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  rsync -a "${@:2}" "$src" "$dst"
  info "$1"
}

section "Hyprland"
rsync_cfg hypr/

section "Waybar"
rsync_cfg waybar/

section "Notifications (mako)"
rsync_cfg mako/

section "App launcher (walker)"
rsync_cfg walker/

section "Terminals"
rsync_cfg alacritty/
rsync_cfg kitty/
rsync_cfg ghostty/

section "Shell & prompt"
rsync_cfg fish/
rsync_cfg starship.toml

section "Multiplexer (tmux)"
rsync_cfg tmux/

section "TUI tools"
rsync_cfg btop/
rsync_cfg fastfetch/
rsync_cfg lazygit/

section "Dock"
rsync_cfg nwg-dock-hyprland/

section "hypr-overview"
rsync_cfg hypr-overview/
rsync_cfg quickshell/hypr-overview/

section "Omarchy"
# Copy themes as plain directories (their .git dirs are not tracked here;
# Omarchy manages the `current` symlink and `themed/` dir — leave those alone)
rsync_cfg omarchy/backgrounds/
rsync_cfg omarchy/branding/
rsync_cfg omarchy/extensions/
rsync_cfg omarchy/hooks/
rsync_cfg omarchy/themes/

section "Editor (nvim)"
rsync_cfg nvim/

section "Git"
rsync_cfg git/

section "Audio"
rsync_cfg wiremix/

section "OSD"
rsync_cfg swayosd/

section "Environment"
rsync_cfg environment.d/

# ── Webapp icon sync ────────────────────────────────────────────────────────

section "Webapp icon sync"

# Install the sync script
mkdir -p "$HOME/.local/bin"
cp "$DOTFILES/scripts/sync-webapp-icons" "$HOME/.local/bin/sync-webapp-icons"
chmod +x "$HOME/.local/bin/sync-webapp-icons"
success "sync-webapp-icons script installed"

# Install and enable the systemd path watcher
rsync_cfg systemd/user/sync-webapp-icons.service
rsync_cfg systemd/user/sync-webapp-icons.path
systemctl --user daemon-reload
systemctl --user enable --now sync-webapp-icons.path
success "sync-webapp-icons.path watcher enabled"

# Populate iconMappings from any already-installed webapps
if [[ -f "$HOME/.config/hypr-overview/config.json" ]]; then
  "$HOME/.local/bin/sync-webapp-icons" && success "webapp icon mappings synced"
fi

# ── MX Master input ─────────────────────────────────────────────────────────

section "MX Master input"

mkdir -p "$HOME/.local/bin"
for script in hypr-cycle-nowrap thumbwheel-cycler.py; do
  cp "$DOTFILES/scripts/$script" "$HOME/.local/bin/$script"
  chmod +x "$HOME/.local/bin/$script"
  success "$script installed"
done

rsync_cfg systemd/user/thumbwheel-cycler.service
systemctl --user daemon-reload
systemctl --user enable --now thumbwheel-cycler.service
success "thumbwheel-cycler.service enabled"
info "Note: thumbwheel-cycler.py uses /dev/input/event6 — verify device path on this machine"

# ── MX Brio virtual camera (flipped) ────────────────────────────────────────

section "MX Brio flipped virtual camera"

if ! pacman -Q v4l2loopback-dkms &>/dev/null; then
  info "Installing v4l2loopback-dkms and linux-headers..."
  sudo pacman -S --noconfirm linux-headers v4l2loopback-dkms
fi

sudo cp "$DOTFILES/etc/modprobe.d/v4l2loopback.conf" /etc/modprobe.d/v4l2loopback.conf
sudo cp "$DOTFILES/etc/modules-load.d/v4l2loopback.conf" /etc/modules-load.d/v4l2loopback.conf
sudo modprobe v4l2loopback
success "v4l2loopback loaded → /dev/video10 (MX Brio Flipped)"

rsync_cfg systemd/user/brio-flip.service
systemctl --user daemon-reload
systemctl --user enable --now brio-flip.service
success "brio-flip.service enabled"

# ── Reload live services ────────────────────────────────────────────────────

if $LIVE; then
  section "Reloading live services"

  hyprctl reload &>/dev/null && success "Hyprland reloaded" || info "Hyprland reload skipped"

  if pgrep -x waybar &>/dev/null; then
    pkill -SIGUSR2 waybar && success "Waybar reloaded" || info "Waybar reload skipped"
  fi

  if command -v makoctl &>/dev/null; then
    makoctl reload &>/dev/null && success "Mako reloaded" || info "Mako reload skipped"
  fi

  echo
  echo "Done. Theme changes take effect when you switch themes via omarchy-menu."
else
  echo
  echo "Done. Start Hyprland to apply the configuration."
fi

echo
echo "To apply a specific theme, run: omarchy-theme <theme-name>"
echo "Available themes in this repo: aetheria, city-783, event-horizon, zachs-theme"
