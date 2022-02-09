#!/usr/bin/env bash

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/filipstefansson/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install languages etc
brew install zsh
brew install git
brew install tree
brew install ack
brew install fnm

# Install apps
brew install --cask visual-studio-code
brew install --cask google-chrome
brew install --cask spotify
brew install --cask github
brew install --cask slack
brew install --cask iterm2
brew install --cask 1password
brew install --cask figma
brew install --cask docker

brew cleanup
