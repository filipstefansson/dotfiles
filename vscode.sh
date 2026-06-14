#!/usr/bin/env bash

# Install VS Code extensions declaratively. Mirrors `code --list-extensions`.
# Re-running is idempotent (already-installed extensions are skipped).

if ! command -v code &>/dev/null; then
  echo "VS Code 'code' CLI not found on PATH — skipping extensions."
  echo "Open VS Code and run: Shell Command: Install 'code' command in PATH"
  exit 0
fi

# Bare minimum for TS/Next.js and Flutter dev.
extensions=(
  # TypeScript / Next.js
  dbaeumer.vscode-eslint
  esbenp.prettier-vscode
  bradlc.vscode-tailwindcss
  yoavbls.pretty-ts-errors
  unifiedjs.vscode-mdx
  # Flutter / Dart
  dart-code.flutter
  dart-code.dart-code
  # Git
  eamodio.gitlens
)

for ext in "${extensions[@]}"; do
  code --install-extension "$ext" --force
done
