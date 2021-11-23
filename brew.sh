#!/usr/bin/env bash

# Install homebrew
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/filipstefansson/.zprofile
# eval "$(/opt/homebrew/bin/brew shellenv)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install languages etc
brew install zsh
brew install git

# Install apps
brew cask install visual-studio-code
brew cask install google-chrome
brew cask install spotify
brew cask install github
brew cask install slack
brew cask install iterm2
brew cask install 1password
brew cask install figma
brew cask install docker

brew cleanup
