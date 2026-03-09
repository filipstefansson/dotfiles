# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles. Manages shell (zsh), Homebrew packages/casks, Node.js (via fnm), and macOS system preferences.

## Installation

- Full install: `./install.sh` (runs brew.sh, zsh.sh, npm.sh, symlinks .zshrc)
- Individual scripts can be run standalone: `./brew.sh`, `./zsh.sh`, `./npm.sh`
- macOS preferences: `./.macos` (review before running — sets keyboard, Finder, Dock, etc.)
- The repo path is auto-detected by `install.sh` — it can live anywhere

## Architecture

- **install.sh** — Entry point. Pulls latest, runs all setup scripts, symlinks `.zshrc`
- **brew.sh** — Installs Homebrew, CLI tools (git, fnm, eza, zoxide, pnpm, starship, bat, gh, fd, ripgrep, jq), and GUI apps via casks (VS Code, Chrome, Ghostty, etc.)
- **zsh.sh** — Installs Oh-My-Zsh and custom plugins (git-open, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
- **npm.sh** — Installs Node.js v22 (LTS) via fnm and sets up pnpm
- **.zshrc** — Shell config: Oh-My-Zsh with Starship prompt, eza/zoxide integration, fnm init, auto-ls on cd
- **.macos** — macOS system preference tweaks (keyboard, Finder, Dock, Mail, screenshots, etc.)

## Key Details

- Node version management uses **fnm** (not nvm)
- Package management uses **pnpm** as the primary package manager
- Shell prompt is **Starship** (installed via Homebrew, configured in `.config/starship.toml`)
- **eza** replaces `ls` and `tree` — aliased in `.zshrc`
- **zoxide** replaces `cd` — initialized in `.zshrc` with a Claude Code guard (`CLAUDECODE` env var)
- Terminal emulator is **Ghostty** (replaced iTerm2)
- `.zshrc` is symlinked from repo to `~/.zshrc` — edits here are the source of truth
- All scripts are bash (`#!/usr/bin/env bash`) except the shell config which is zsh
