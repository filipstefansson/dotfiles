#!/usr/bin/env bash

# Install stuff
./brew.sh

# Configure zsh
./zsh.sh

# Install VSCode extensions

# symlink zshrc file
ln -sv ~/code/dotfiles/.zshrc ~
