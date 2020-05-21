#!/usr/bin/env bash

# Download latest
git pull origin master

# Install stuff
./brew.sh

# Configure zsh
./zsh.sh

# Install VSCode extensions
./vscode.sh

# symlink zshrc file
ln -sv ~/code/dotfiles/.zshrc ~
