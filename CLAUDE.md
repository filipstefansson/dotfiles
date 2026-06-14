# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles. Manages shell (zsh), Homebrew packages/casks, Node.js (via fnm), Python tooling (via uv), Java tooling (Homebrew OpenJDK), and macOS system preferences.

## Installation

- Full install: `./install.sh` (runs brew.sh, zsh.sh, npm.sh, rust.sh, vscode.sh, skills.sh, symlinks dotfiles)
- Individual scripts can be run standalone: `./brew.sh`, `./zsh.sh`, `./npm.sh`, `./rust.sh`, `./vscode.sh`, `./skills.sh`
- macOS preferences: `./.macos` (review before running — sets keyboard, Finder, Dock, etc.)
- The repo path is auto-detected by `install.sh` — it can live anywhere

## Architecture

- **install.sh** — Entry point. Pulls latest, runs all setup scripts, symlinks `.zshrc`
- **Brewfile** — Declarative list of Homebrew formulae and casks.
- **brew.sh** — Installs Homebrew, updates/upgrade packages, runs `brew bundle` against `Brewfile`, then cleans Homebrew caches.
- **zsh.sh** — Installs Oh-My-Zsh and custom plugins (git-open, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
- **npm.sh** — Installs Node.js v24 (LTS) via fnm and a default Python via uv
- **vscode.sh** — Installs VS Code extensions declaratively (`code --install-extension`, idempotent)
- **rust.sh** — Installs the Rust toolchain via rustup, adds clippy/rustfmt/rust-analyzer, and installs cargo-nextest/bacon via cargo-binstall
- **skills.sh** — Reinstalls agent skills via the `skills` CLI (`npx skills add <repo>`), installed globally and symlinked into Claude + Codex. Runs after npm.sh (needs Node)
- **.zshrc** — Shell config: Oh-My-Zsh with Starship prompt, guarded eza/zoxide/fnm/fzf/bat integrations, `~/.local/bin` (uv Python shims) on PATH, Homebrew OpenJDK setup, auto-ls on cd
- **.config/zsh/local.zsh.example** — Template for machine-specific paths such as Flutter, Android, Shorebird, and Rust.
- **.macos** — macOS system preference tweaks (keyboard, Finder, Dock, Mail, screenshots, etc.)

## Key Details

- Node version management uses **fnm** (not nvm)
- Package management uses **pnpm** as the primary package manager
- Python uses **uv** end to end — it installs the default interpreter (`uv python install --default`, shims in `~/.local/bin`) and handles project/tool workflows
- Java uses **Homebrew OpenJDK pinned to `openjdk@21`** (LTS) for the machine-level JDK — chosen for Android/Flutter/Gradle compatibility (latest `openjdk` is too new for AGP)
- Rust uses **rustup** (not Homebrew's `rust`); `rust.sh` sets it up, `.zshrc` sources `~/.cargo/env`, and `~/.cargo/config.toml` (symlinked) configures `sccache` + `target-cpu=native`
- Shell prompt is **Starship** (installed via Homebrew, configured in `.config/starship.toml`)
- **eza** replaces `ls` and `tree` — aliased in `.zshrc`
- **zoxide** replaces `cd` — initialized in `.zshrc` with a Claude Code guard (`CLAUDECODE` env var)
- Terminal emulator is **Ghostty** (replaced iTerm2)
- `.zshrc` is symlinked from repo to `~/.zshrc` — edits here are the source of truth
- Machine-specific shell paths should go in `~/.config/zsh/local.zsh`, not directly in `.zshrc`
- All scripts are bash (`#!/usr/bin/env bash`) except the shell config which is zsh
- Git uses **git-delta** as the pager/diff viewer, a global ignore file (`.gitignore_global` via `core.excludesfile`), and **1Password's SSH agent** for commit signing (`gpg.format = ssh`)

## Agent machine (this box only — NOT part of the default install)

One machine doubles as an always-on agent/CI box. It's a **two-layer** setup:

- **Layer 1 — identical dev machine.** `./install.sh` exactly as on any other Mac. Nothing below changes Layer 1, so the repo stays portable.
- **Layer 2 — runner overlay.** `./agent.sh`, run **once on this box, after** `install.sh`. Order: wipe → `install.sh` → `agent.sh`. `agent.sh` is **never** called by `install.sh`.

- **agent.sh** — Idempotent overlay. Always-on power settings (`pmset` auto-restart on power loss/freeze; Amphetamine handles keep-awake; auto-login is a guided manual step), Tailscale + SSH, installs `fastlane` (Layer-2 only — deliberately not in the shared Brewfile), writes the runner toolchain env, then registers the runners in `runners.conf`. Registration tokens are minted on the fly via `gh api` (needs `gh` authed with admin scope) — nothing is stored.
- **runners.conf** — One line per runner (`name  scope-url  labels`). One **org-level** runner covers all of an org's private repos; **personal repos each need their own repo-level line** (user accounts have no account-wide runner level). Keep it short — each runner = 1 concurrent job on old hardware.
- **~/runners/** — Per-runner dirs + `agent-env.sh`. Runners are **native + persistent** (no Docker: macOS can't containerize Xcode/iOS; `container:` jobs are Linux-only). Jobs run non-interactive, so a `.path` file per runner puts cargo/node/brew on PATH — this is what makes **Rust/Bevy** jobs work (base `rust.sh` toolchain is sufficient; no extra system deps for Bevy on macOS).
- **External SSD (`$CI_VOLUME`, default `/Volumes/CI`)** — Holds only **bulk, regenerable** data so the 512 internal disk doesn't fill: `CARGO_TARGET_DIR` + `SCCACHE_DIR` (set in each runner's `.env` + `agent-env.sh`), runner `_work` dirs (`config.sh --work`), and symlinked Xcode `DerivedData`/`Archives`/`iOS DeviceSupport` + CoreSimulator `Devices`. Toolchains/config stay internal, so the box still works (cold) if the drive drops. `agent.sh` **aborts** if the drive isn't mounted (never silently uses the internal disk); add the printed snippet to `local.zsh` for interactive builds.
- **examples/ci/** — Reference files for the *app* repos (not used by this repo): `ios-release.yml`, `Fastfile`, and `secrets.md`. iOS submission is fully automated via **`fastlane match` + a throwaway CI keychain** (`setup_ci`) and an **App Store Connect API key** — so signing never uses the login keychain, 1Password, or 2FA. **Git commit signing is skipped in CI** (the 1Password SSH agent can't run headless).
- **Future:** containerized non-iOS jobs should go to a **separate Linux runner**, not this Mac.
