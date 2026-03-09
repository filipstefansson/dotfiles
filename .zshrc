# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
DISABLE_AUTO_TITLE="true"

# FNM (Node versions)
eval "$(fnm env --use-on-cd --shell zsh)"

# zoxide (smarter cd)
if [[ "$CLAUDECODE" != "1" ]]; then
  eval "$(zoxide init zsh)"
  alias cd='z'
  alias ccd='builtin cd'
fi

# Plugins
plugins=(
  git
  git-open
  zsh-completions
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# History (after oh-my-zsh to avoid being overridden)
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Editor
export EDITOR="code --wait"
export VISUAL="$EDITOR"

# eza (smarter ls)
_eza_opts='--long --git --no-user --no-permissions --time-style=relative --color=always --group-directories-first --icons'
alias ls="eza $_eza_opts"

# Auto-list dir after cd
ls-on-chpwd() { eza ${=_eza_opts} }
chpwd_functions+=(ls-on-chpwd)

# bat (smarter cat)
alias cat='bat'

# fzf (fuzzy finder)
source <(fzf --zsh)

# Starship prompt
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
