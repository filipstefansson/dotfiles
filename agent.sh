#!/usr/bin/env bash

# Agent / CI overlay — THIS MACHINE ONLY. Run once, AFTER ./install.sh.
#
# Turns the base dev machine into an always-on box that hosts self-hosted
# GitHub Actions runners (build/test, Rust/Bevy, iOS submission, AI agents).
# Deliberately NOT wired into install.sh — the new Mac never runs this.
#
# Idempotent / re-runnable. Layer 1 (install.sh) is untouched by this script;
# it only adds things on top. See CLAUDE.md "Agent machine" for the full story.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNERS_DIR="$HOME/runners"
ENV_FILE="$RUNNERS_DIR/agent-env.sh"
RUNNERS_CONF="$DOTFILES_DIR/runners.conf"

# External SSD for bulk, regenerable data (Rust artifacts/cache, Xcode, runner
# work dirs). The 512 internal disk holds toolchains + config only, so the box
# still works (cold/slow) if the drive is ever detached. Override by exporting
# CI_VOLUME before running. The path = /Volumes/<APFS volume name>.
CI_VOLUME="${CI_VOLUME:-/Volumes/CI}"
CARGO_TARGET_DIR="$CI_VOLUME/cargo-target" # the Bevy `target/` monster
SCCACHE_DIR="$CI_VOLUME/sccache"
RUNNER_WORK_ROOT="$CI_VOLUME/runner-work"

# Make brew/cargo resolve in this script even on a fresh shell (like rust.sh).
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
# shellcheck source=/dev/null
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
ask() {
  local q="$1"
  read -r -p "  ? $q [y/N] " a
  [[ "$a" =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# 1. Preflight — the base install must have run first.
# ---------------------------------------------------------------------------
log "Preflight"
for tool in brew gh cargo; do
  if ! command -v "$tool" &>/dev/null; then
    warn "'$tool' not found — run ./install.sh first. Aborting."
    exit 1
  fi
done
gh auth status &>/dev/null || {
  warn "Run 'gh auth login' first (needs admin scope on the target repos/org)."
  exit 1
}
echo "  base toolchain present."

# The external SSD must be mounted — bulk data lives there and we refuse to
# silently fall back to the 512 internal disk. Abort with instructions if absent.
if [ ! -d "$CI_VOLUME" ]; then
  warn "External SSD not mounted at $CI_VOLUME — aborting."
  echo "  1. Attach the drive."
  echo "  2. In Disk Utility, erase it as APFS and name it 'CI' (the name sets the"
  echo "     mount path /Volumes/CI). Use CI_VOLUME=/Volumes/<name> if named differently."
  echo "  3. Re-run ./agent.sh."
  exit 1
fi
echo "  SSD mounted at $CI_VOLUME."
mkdir -p "$CARGO_TARGET_DIR" "$SCCACHE_DIR" "$RUNNER_WORK_ROOT"

# ---------------------------------------------------------------------------
# 2. Always-on — survive sleep, power loss, and freezes (guarded, needs sudo).
# ---------------------------------------------------------------------------
log "Always-on power settings"
if ask "Apply always-on power settings (auto-restart on power loss + freeze, no sleep)?"; then
  sudo pmset -a autorestart 1
  sudo pmset -a sleep 0 disablesleep 1
  sudo systemsetup -setrestartfreeze on
  echo "  pmset/systemsetup applied."
else
  warn "Skipped power settings."
fi

echo
echo "  Amphetamine (already installed via the Brewfile) handles keep-awake."
echo "  In its GUI: enable 'Launch at login' + a default indefinite session / trigger."
echo
echo "  Auto-login (so Amphetamine + runners come back after a reboot) must be set"
echo "  in System Settings > Users & Groups > Automatically log in as. Requires"
echo "  FileVault to be OFF on this box."
if ask "Open that settings pane now?"; then
  open "x-apple.systempreferences:com.apple.preferences.users" || true
fi

# ---------------------------------------------------------------------------
# 3. Remote access — Tailscale + SSH (reach the box from anywhere).
# ---------------------------------------------------------------------------
log "Remote access"
if ! command -v tailscale &>/dev/null && ! [ -d "/Applications/Tailscale.app" ]; then
  brew install --cask tailscale
fi
if ask "Enable Remote Login (SSH)?"; then
  sudo systemsetup -setremotelogin on
fi
echo "  Run 'tailscale up' (or open the Tailscale app) to join your tailnet."

# ---------------------------------------------------------------------------
# 4. CI tooling — fastlane (Layer-2 only; not in the shared Brewfile).
# ---------------------------------------------------------------------------
log "CI tooling"
command -v fastlane &>/dev/null || brew install fastlane
echo "  fastlane: $(fastlane --version 2>/dev/null | awk '/fastlane [0-9]/{print $2; exit}')"

# ---------------------------------------------------------------------------
# 5. Runner toolchain env — make the toolchain visible to NON-interactive jobs.
#    Jobs don't load interactive zsh, so PATH/cargo/fnm must be set explicitly.
#    Sourced via a `.path` file dropped into each runner dir below, and also
#    available as agent-env.sh for workflows that prefer to `source` it.
# ---------------------------------------------------------------------------
log "Runner toolchain env -> $ENV_FILE"
mkdir -p "$RUNNERS_DIR"
cat >"$ENV_FILE" <<'EOF'
# Auto-generated by agent.sh — toolchain for non-interactive CI jobs.
# Source this at the top of a job, or rely on the per-runner `.path` file.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -r "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"   # cargo/rustc + ~/.cargo/config.toml (sccache, target-cpu=native)
export PATH="$HOME/.local/bin:$PATH"                 # uv python shims
command -v fnm &>/dev/null && eval "$(fnm env)"      # node via fnm
EOF
# Append the SSD redirects (interpolated, so the unquoted heredoc is intentional).
cat >>"$ENV_FILE" <<EOF

# External SSD — bulk Rust caches/artifacts only (toolchain stays internal).
# Fail loud if the drive is gone rather than writing GBs to the internal disk.
if [ ! -d "$CI_VOLUME" ]; then
  echo "WARNING: CI volume $CI_VOLUME not mounted — Rust caches/artifacts unavailable." >&2
else
  export CARGO_TARGET_DIR="$CARGO_TARGET_DIR"
  export SCCACHE_DIR="$SCCACHE_DIR"
fi
EOF
echo "  wrote $ENV_FILE"

# Resolve the static toolchain dirs for the runner `.path` files. Rust/Bevy
# jobs (the cargo bits) only need ~/.cargo/bin + homebrew on PATH.
NODE_BIN=""
if command -v fnm &>/dev/null; then
  NODE_BIN="$(dirname "$(fnm exec --using=default which node 2>/dev/null)" 2>/dev/null || true)"
fi
RUNNER_PATH_DIRS=(
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "$NODE_BIN"
  "/usr/bin" "/bin" "/usr/sbin" "/sbin"
)

# ---------------------------------------------------------------------------
# 5b. Offload Xcode / CoreSimulator bulk dirs onto the SSD via symlink.
#     Each gets a dangling link if the drive is ever gone, so Xcode fails fast
#     instead of silently refilling the internal disk.
# ---------------------------------------------------------------------------
log "Xcode / simulator storage -> $CI_VOLUME"
link_to_ssd() { # <internal path> <ssd path>
  local src="$1" dest="$2"
  mkdir -p "$dest"
  if [ -L "$src" ]; then
    echo "  $src -> already linked."
    return 0
  fi
  if [ -e "$src" ]; then
    warn "$src has real data on the internal disk."
    warn "  Move it to $dest (rsync + rm), then re-run. Skipping for now."
    return 0
  fi
  mkdir -p "$(dirname "$src")"
  ln -sfnv "$dest" "$src"
}
link_to_ssd "$HOME/Library/Developer/Xcode/DerivedData" "$CI_VOLUME/DerivedData"
link_to_ssd "$HOME/Library/Developer/Xcode/Archives" "$CI_VOLUME/Xcode-Archives"
link_to_ssd "$HOME/Library/Developer/Xcode/iOS DeviceSupport" "$CI_VOLUME/iOS-DeviceSupport"
link_to_ssd "$HOME/Library/Developer/CoreSimulator/Devices" "$CI_VOLUME/CoreSimulator-Devices"
# Note: simulator *runtimes* are Xcode-managed and stored separately — not moved here.

# ---------------------------------------------------------------------------
# 6. Register the runners listed in runners.conf.
#    Registration tokens are minted on the fly via `gh api` (short-lived,
#    never stored). Scope = org vs repo is inferred from the URL.
# ---------------------------------------------------------------------------
log "GitHub Actions runners"
if [ ! -f "$RUNNERS_CONF" ]; then
  warn "No runners.conf found at $RUNNERS_CONF — skipping runner setup."
  exit 0
fi

# Latest runner package for this Mac (Apple Silicon).
RUNNER_VERSION="$(gh api repos/actions/runner/releases/latest --jq .tag_name | sed 's/^v//')"
RUNNER_TGZ="actions-runner-osx-arm64-${RUNNER_VERSION}.tar.gz"
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TGZ}"
echo "  runner version: $RUNNER_VERSION"

# mint_token <scope-url> -> prints a registration token
mint_token() {
  local url="$1" path
  # https://github.com/OWNER/REPO  -> repos/OWNER/REPO ; https://github.com/ORG -> orgs/ORG
  local slug="${url#https://github.com/}"
  if [[ "$slug" == */* ]]; then
    path="repos/${slug}"
  else
    path="orgs/${slug}"
  fi
  gh api -X POST "${path}/actions/runners/registration-token" --jq .token
}

# Read the conf on FD 3 so sudo/config.sh inside the loop keep their own stdin.
while read -r name scope labels <&3; do
  # skip blanks and comments
  [[ -z "${name:-}" || "$name" == \#* ]] && continue

  dir="$RUNNERS_DIR/$name"
  if [ -f "$dir/.runner" ]; then
    echo "  [$name] already configured — skipping."
    continue
  fi

  log "Configuring runner '$name' for $scope"
  mkdir -p "$dir"
  if [ ! -x "$dir/config.sh" ]; then
    curl -fsSL "$RUNNER_URL" -o "$dir/$RUNNER_TGZ"
    tar xzf "$dir/$RUNNER_TGZ" -C "$dir"
    rm -f "$dir/$RUNNER_TGZ"
  fi

  token="$(mint_token "$scope")"
  mkdir -p "$RUNNER_WORK_ROOT/$name"
  (cd "$dir" && ./config.sh \
    --url "$scope" \
    --token "$token" \
    --name "$(hostname -s)-$name" \
    --labels "$labels" \
    --work "$RUNNER_WORK_ROOT/$name" \
    --unattended --replace)

  # PATH for non-interactive jobs (this is what makes cargo/node/brew resolve).
  printf '%s\n' "${RUNNER_PATH_DIRS[@]}" | awk 'NF' | paste -sd: - >"$dir/.path"

  # Env the runner injects into every job — point bulk Rust storage at the SSD.
  cat >"$dir/.env" <<EOF
CARGO_TARGET_DIR=$CARGO_TARGET_DIR
SCCACHE_DIR=$SCCACHE_DIR
EOF

  # Install as a user-session service so it auto-starts and Xcode/simulators work.
  (cd "$dir" && sudo ./svc.sh install "$(whoami)" && sudo ./svc.sh start)
  echo "  [$name] installed and started."
done 3<"$RUNNERS_CONF"

log "Done. Check Settings > Actions > Runners for green 'Idle' runners."

cat <<EOF

  For your INTERACTIVE shell to also use the SSD, add to ~/.config/zsh/local.zsh:

    # Agent box: route bulk Rust storage to the external SSD (toolchain stays internal).
    if [ -d "$CI_VOLUME" ]; then
      export CARGO_TARGET_DIR="$CARGO_TARGET_DIR"
      export SCCACHE_DIR="$SCCACHE_DIR"
    fi
EOF
