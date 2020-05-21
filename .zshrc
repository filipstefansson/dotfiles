# Path to your oh-my-zsh installation.
export ZSH="/Users/filipstefansson/.oh-my-zsh"

ZSH_THEME="vercel"

plugins=(
  git
  node
  yarn
  git-extras
  colorize
  zsh-syntax-highlighting
  zsh-autosuggestions
  git-open
)

source $ZSH/oh-my-zsh.sh

# Do ls after cd
chpwd() {
  ls
}
