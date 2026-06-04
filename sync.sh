#!/usr/bin/env bash
# Syncs config files into this repo and commits+pushes if anything changed.
# Safe to run repeatedly; no-ops when nothing has changed.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config"

rsync_cfg() {
  local src="$CFG/$1" dst="$DOTFILES/.config/$1"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  rsync -a --delete "${@:2}" "$src" "$dst"
}

rsync_file() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  rsync -a "$src" "$dst"
}

# Desktop / WM
rsync_cfg hypr/
rsync_cfg waybar/
rsync_cfg mako/
rsync_cfg walker/
rsync_cfg omarchy/ \
  --exclude='.git' \
  --exclude='current' \
  --exclude='themed/' \
  --exclude='backgrounds/*.png' \
  --exclude='backgrounds/*.jpg' \
  --exclude='backgrounds/*.jpeg' \
  --exclude='backgrounds/*.webp'

# Elephant (walker data provider — menus, etc.)
rsync_cfg elephant/

# Dock
rsync_cfg nwg-dock-hyprland/

# hypr-overview (config + QML source)
rsync_cfg hypr-overview/
rsync_cfg quickshell/hypr-overview/

# Systemd user units (individual files, not the whole directory)
rsync_cfg systemd/user/sync-webapp-icons.service
rsync_cfg systemd/user/sync-webapp-icons.path
rsync_cfg systemd/user/thumbwheel-cycler.service
rsync_cfg systemd/user/brio-flip.service

# System-level configs (stored under etc/ in the repo)
rsync_etc() {
  local src="/etc/$1" dst="$DOTFILES/etc/$1"
  [[ -e "$src" ]] || return 0
  mkdir -p "$(dirname "$dst")"
  rsync -a "$src" "$dst"
}
rsync_etc modprobe.d/v4l2loopback.conf
rsync_etc modules-load.d/v4l2loopback.conf
rsync_etc systemd/system-sleep/ish-accel-reload.sh

# Terminals
rsync_cfg alacritty/
rsync_cfg kitty/
rsync_cfg ghostty/

# Shell / prompt
rsync_file "$HOME/.bashrc" "$DOTFILES/home/.bashrc"
rsync_file "$HOME/.zshrc" "$DOTFILES/home/.zshrc"
rsync_cfg fish/
rsync_cfg starship.toml

# Multiplexer
rsync_cfg tmux/

# TUI tools
rsync_cfg btop/
rsync_cfg fastfetch/
rsync_cfg lazygit/

# Editor
rsync_cfg nvim/ --exclude='.git'

# Git
rsync_cfg git/

# Audio / OSD
rsync_cfg wiremix/
rsync_cfg swayosd/

# Environment
rsync_cfg environment.d/

# Local bin scripts
rsync_file "$HOME/.local/bin/sync-webapp-icons" "$DOTFILES/scripts/sync-webapp-icons"
rsync_file "$HOME/.local/bin/hypr-cycle-nowrap" "$DOTFILES/scripts/hypr-cycle-nowrap"
rsync_file "$HOME/.local/bin/thumbwheel-cycler.py" "$DOTFILES/scripts/thumbwheel-cycler.py"

cd "$DOTFILES"

if git diff --quiet && git diff --staged --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  echo "dotfiles: no changes to commit"
  exit 0
fi

git add -A

# Build a descriptive commit message from the staged files
STAGED=$(git diff --staged --name-only)
FILE_COUNT=$(printf '%s\n' "$STAGED" | grep -c '.')
# Extract config area (e.g. "hypr", "waybar") — skip root-level files like sync.sh
DIRS=$(printf '%s\n' "$STAGED" | sed 's|^\.config/||' | awk -F/ 'NF>1{print $1}' | sort -u | awk '{r=r (r?", ":"") $0} END{print r}')
FILES=$(printf '%s\n' "$STAGED" | awk -F/ '{print $NF}' | sort -u | awk '{r=r (r?", ":"") $0} END{print r}')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

if [ "$FILE_COUNT" -le 5 ]; then
  COMMIT_MSG="${DIRS}: update ${FILES} [${TIMESTAMP}]"
else
  COMMIT_MSG="dotfiles: update ${DIRS} (${FILE_COUNT} files) [${TIMESTAMP}]"
fi

git commit -m "$COMMIT_MSG"

if git remote get-url origin &>/dev/null; then
  git push
  echo "dotfiles: committed and pushed"
else
  echo "dotfiles: committed locally (no remote configured)"
fi
