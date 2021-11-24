# Path to your oh-my-zsh installation.
export ZSH="/Users/filipstefansson/.oh-my-zsh"

export NVM_LAZY_LOAD=true

plugins=(
  git
  zsh-nvm
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

SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_NODE_SHOW=true
SPACESHIP_DOCKER_SHOW=false
SPACESHIP_GCLOUD_SHOW=false
SPACESHIP_AWS_SHOW=false

fpath=($fpath "/Users/filipstefansson/.zfunctions")

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt spaceship

ZSH_THEME="spaceship"
