#!/usr/bin/env bash

# Install the Rust toolchain via rustup, plus components and dev tools.
# Idempotent — safe to re-run. rustup/sccache/cargo-binstall come from the Brewfile.

# Put the brewed rustup proxies (cargo, rustc, …) on PATH for this script.
# The brew rustup formula is keg-only, so these aren't symlinked into
# /opt/homebrew/bin — they have to be added explicitly. .zshrc does the same
# for interactive shells.
rustup_prefix="$(brew --prefix rustup 2>/dev/null)"
if [ -n "$rustup_prefix" ] && [ -d "$rustup_prefix/bin" ]; then
  export PATH="$rustup_prefix/bin:$HOME/.cargo/bin:$PATH"
elif ! command -v rustup &>/dev/null; then
  # Fallback to the official installer if brew's rustup isn't around.
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  [ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

# Keep stable up to date and add the components we want everywhere.
rustup update stable
rustup component add clippy rustfmt rust-analyzer

# Dev tools via cargo-binstall (downloads prebuilt binaries — much faster than
# compiling from source).
if command -v cargo-binstall &>/dev/null; then
  cargo binstall -y cargo-nextest bacon
else
  echo "cargo-binstall not found — skipping cargo-nextest/bacon (install via Brewfile)."
fi
