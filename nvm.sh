#!/usr/bin/env bash

set -e

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | sh

# Download last stable Node.JS version
node_version="0.10"
nvm install $node_version

# Set stable version as default version
nvm alias default $node_version

# Install packages
npm install -g yarn
npm install -g spaceship-prompt
