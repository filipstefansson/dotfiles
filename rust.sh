#!/usr/bin/env bash

# Install the Rust toolchain via rustup, plus components and dev tools.
# Idempotent — safe to re-run. rustup/sccache/cargo-binstall come from the Brewfile.

# Install the toolchain if rustup hasn't set one up yet.
if [ ! -x "$HOME/.cargo/bin/rustup" ] && ! command -v rustup &>/dev/null; then
  # Homebrew's rustup is keg-only, so rustup-init isn't on PATH — call it directly.
  rustup_init="$(brew --prefix 2>/dev/null)/opt/rustup/bin/rustup-init"
  if [ -x "$rustup_init" ]; then
    "$rustup_init" -y --no-modify-path
  else
    # Fallback to the official installer if the brew formula isn't present.
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
fi

# Make cargo/rustup available for the rest of this script (PATH is set in .zshrc).
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

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
