#!/usr/bin/env bash

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install languages
brew install zsh
brew install php
brew install node
brew install git

# Install apps
brew cask install visual-studio-code
brew cask install google-chrome
brew cask install spotify
brew cask install github
brew cask install slack
brew cask install iterm2
brew cask install dropbox
brew cask install 1password

brew cleanup
