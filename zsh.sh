#!/usr/bin/env bash

# oh-my-zsh
git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh

# Change shell
chsh zsh

# Plugins and theme
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
curl https://raw.githubusercontent.com/zeit/zsh-theme/master/vercel.zsh-theme -Lo $HOME/.oh-my-zsh/custom/themes/vercel.zsh-theme
