#!/usr/bin/env bash

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

# Plugins
clone_plugin() {
  local dest="$HOME/.oh-my-zsh/custom/plugins/$(basename "$1" .git)"
  [ -d "$dest" ] || git clone "$1" "$dest"
}

clone_plugin https://github.com/paulirish/git-open.git &
clone_plugin https://github.com/zsh-users/zsh-autosuggestions &
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git &
clone_plugin https://github.com/zsh-users/zsh-completions &
wait
