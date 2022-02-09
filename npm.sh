#!/usr/bin/env bash

# Install node using fnm
eval "$(fnm env)"
fnm install 16.13.1
fnm use 16.13.1

# Install packages
npm install -g yarn
npm install -g spaceship-prompt
