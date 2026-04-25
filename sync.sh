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

# Dock
rsync_cfg nwg-dock-hyprland/

# Terminals
rsync_cfg alacritty/
rsync_cfg kitty/
rsync_cfg ghostty/

# Shell / prompt
rsync_cfg fish/
rsync_cfg starship.toml

# Multiplexer
rsync_cfg tmux/

# TUI tools
rsync_cfg btop/
rsync_cfg fastfetch/
rsync_cfg lazygit/

cd "$DOTFILES"

if git diff --quiet && git diff --staged --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  echo "dotfiles: no changes to commit"
  exit 0
fi

git add -A
git commit -m "Update dotfiles [$(date '+%Y-%m-%d %H:%M')]"

if git remote get-url origin &>/dev/null; then
  git push
  echo "dotfiles: committed and pushed"
else
  echo "dotfiles: committed locally (no remote configured)"
fi
