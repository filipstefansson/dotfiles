#!/usr/bin/env bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Download latest unless explicitly skipped.
if [ "${DOTFILES_SKIP_PULL:-0}" != "1" ]; then
  git -C "$DOTFILES_DIR" pull origin main
fi

# Install stuff
"$DOTFILES_DIR/brew.sh"

# Put Homebrew on PATH so the child scripts below (and their tools like fnm)
# resolve, even on a first install where ~/.zprofile hasn't been sourced yet.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Configure zsh + install language toolchains (independent, run in parallel)
"$DOTFILES_DIR/zsh.sh" &
"$DOTFILES_DIR/npm.sh" &
"$DOTFILES_DIR/rust.sh" &
wait

# Install VS Code extensions (no-op if the `code` CLI isn't on PATH yet)
"$DOTFILES_DIR/vscode.sh"

# Symlink dotfiles
ln -sfnv "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sfnv "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sfnv "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
ln -sfnv "$DOTFILES_DIR/.hushlogin" "$HOME/.hushlogin"

# Symlink configs
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/zsh" "$HOME/.cargo"
ln -sfnv "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
ln -sfnv "$DOTFILES_DIR/.config/ghostty/config" "$HOME/.config/ghostty/config"
ln -sfnv "$DOTFILES_DIR/.cargo/config.toml" "$HOME/.cargo/config.toml"

if [ ! -e "$HOME/.config/zsh/local.zsh" ]; then
  cp -nv "$DOTFILES_DIR/.config/zsh/local.zsh.example" "$HOME/.config/zsh/local.zsh"
fi
