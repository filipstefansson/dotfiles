#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Download latest
git -C "$DOTFILES_DIR" pull origin master

# Install stuff
"$DOTFILES_DIR/brew.sh"

# Configure zsh + install npm packages (independent, run in parallel)
"$DOTFILES_DIR/zsh.sh" &
"$DOTFILES_DIR/npm.sh" &
wait

# Symlink dotfiles
ln -sfv "$DOTFILES_DIR/.zshrc" ~
ln -sfv "$DOTFILES_DIR/.gitconfig" ~
ln -sfv "$DOTFILES_DIR/.hushlogin" ~

# Symlink configs
mkdir -p ~/.config/ghostty
ln -sfv "$DOTFILES_DIR/.config/starship.toml" ~/.config/starship.toml
ln -sfv "$DOTFILES_DIR/.config/ghostty/config" ~/.config/ghostty/config
