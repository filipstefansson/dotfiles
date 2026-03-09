#!/usr/bin/env bash

# Install homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to PATH (idempotent)
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install CLI tools
brew install zsh git fnm eza zoxide pnpm starship bat gh fd ripgrep jq fzf

# Install apps
brew install --cask visual-studio-code google-chrome spotify github slack \
  ghostty 1password figma raycast cleanshot chatgpt codex stats claude \
  betterdisplay syntax-highlight qlmarkdown

brew cleanup
