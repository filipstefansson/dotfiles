#!/usr/bin/env bash

# Install VS Code extensions declaratively. Mirrors `code --list-extensions`.
# Re-running is idempotent (already-installed extensions are skipped).

if ! command -v code &>/dev/null; then
  echo "VS Code 'code' CLI not found on PATH — skipping extensions."
  echo "Open VS Code and run: Shell Command: Install 'code' command in PATH"
  exit 0
fi

extensions=(
  a5huynh.vscode-ron
  alefragnani.project-manager
  bradlc.vscode-tailwindcss
  dart-code.dart-code
  dart-code.flutter
  dbaeumer.vscode-eslint
  eamodio.gitlens
  esbenp.prettier-vscode
  github.vscode-github-actions
  graphql.vscode-graphql
  graphql.vscode-graphql-syntax
  irongeek.vscode-env
  kevinrose.vsc-python-indent
  mechatroner.rainbow-csv
  ms-python.debugpy
  ms-python.python
  ms-python.vscode-pylance
  ms-python.vscode-python-envs
  patbenatar.advanced-new-file
  unifiedjs.vscode-mdx
  vue.volar
  yoavbls.pretty-ts-errors
  yzhang.markdown-all-in-one
)

for ext in "${extensions[@]}"; do
  code --install-extension "$ext" --force
done
