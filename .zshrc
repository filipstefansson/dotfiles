# Path to your oh-my-zsh installation.
export ZSH="/Users/filipstefansson/.oh-my-zsh"

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

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

# Do ls after cd
chpwd() {
  ls
}

# Set Spaceship ZSH as a prompt
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_NODE_SHOW=true
SPACESHIP_DOCKER_SHOW=false
autoload -U promptinit; promptinit
prompt spaceship

ZSH_THEME="spaceship"
