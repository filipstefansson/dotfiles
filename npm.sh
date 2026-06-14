#!/usr/bin/env bash

# Install node using fnm
eval "$(fnm env)"
fnm install 24
fnm default 24

# Install a default Python via uv (provides python/python3/pip in ~/.local/bin)
if command -v uv &>/dev/null; then
  uv python install 3.14 --default
fi

