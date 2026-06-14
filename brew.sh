#!/usr/bin/env bash

# Homebrew 6.0 makes "ask mode" the default for developers, which would block
# this unattended install on confirmation prompts. Keep brew non-interactive.
unset HOMEBREW_DEVELOPER
export HOMEBREW_NO_ENV_HINTS=1

# Install homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add brew to PATH (idempotent)
if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make sure we're using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install declared tools and apps.
brew bundle --file "$(cd "$(dirname "$0")" && pwd)/Brewfile"

brew cleanup
