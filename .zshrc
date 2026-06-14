# Shell helpers
_has() { command -v "$1" >/dev/null 2>&1 }

# Homebrew shell environment, when available.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# uv installs default python/pip shims into ~/.local/bin.
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" "${path[@]}")

# Homebrew OpenJDK is keg-only, so expose it explicitly. Pinned to JDK 21 (LTS)
# for Android/Flutter compatibility.
if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home" ]]; then
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  path=("$JAVA_HOME/bin" "${path[@]}")
fi

# Rust (rustup/cargo) — adds ~/.cargo/bin to PATH.
[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Machine-local additions belong here, not in the shared dotfiles.
[[ -r "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_TITLE="true"

plugins=(git)
[[ -d "$ZSH/custom/plugins/git-open" || -d "$ZSH/plugins/git-open" ]] && plugins+=(git-open)
[[ -d "$ZSH/custom/plugins/zsh-completions" ]] && plugins+=(zsh-completions)
[[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit
fi

# History
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY        # share history across open shells
setopt EXTENDED_HISTORY     # record timestamps
setopt INC_APPEND_HISTORY   # append as commands run, not on exit
setopt HIST_VERIFY          # confirm before running an expanded !history line
setopt HIST_IGNORE_SPACE    # don't record commands prefixed with a space

# Aliases
alias reload='exec zsh'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editor
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# FNM (Node versions)
_has fnm && eval "$(fnm env --use-on-cd --shell zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PATH:$PNPM_HOME"
if [[ -n "${HOMEBREW_PREFIX:-}" && -x "$HOMEBREW_PREFIX/bin/pnpm" ]]; then
  pnpm() { "$HOMEBREW_PREFIX/bin/pnpm" "$@"; }
fi

# zoxide (smarter cd)
if [[ "$CLAUDECODE" != "1" ]] && _has zoxide; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias ccd='builtin cd'
fi

# eza (smarter ls)
if _has eza; then
  _eza_opts='--long --git --no-user --no-permissions --time-style=relative --color=always --group-directories-first --icons'
  alias ls="eza $_eza_opts"
  alias ll="eza $_eza_opts"
  alias la="eza $_eza_opts --all"
  alias tree='eza --tree --icons'
  ls-on-chpwd() { eza ${=_eza_opts} }
  chpwd_functions+=(ls-on-chpwd)
fi

# bat (smarter file preview)
_has bat && alias ccat='bat --paging=never'

# fzf (fuzzy finder)
if [[ -o interactive && -t 0 && -t 1 && "$TERM" != "dumb" ]] && _has fzf; then
  source <(fzf --zsh)
fi

# Starship prompt
if [[ -o interactive && "$TERM" != "dumb" ]] && _has starship; then
  eval "$(starship init zsh)"
fi
