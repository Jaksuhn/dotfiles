# plugin manager
source ~/antigen/antigen.zsh

# oh my zsh plugins
antigen use oh-my-zsh

# plugins
antigen bundles <<EOBUNDLES
# oh my zsh plugins
command-not-found
colored-man-pages
extract
git
git-extras
universalarchive
virtualenv

# third party plugins
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting

EOBUNDLES

# theme
antigen theme romkatv/powerlevel10k
antigen apply

# defaults
export EDITOR=/usr/bin/micro
export PATH=$PATH:/home/snow/.cargo/bin/tectonic
export ZSH="/home/snow/.oh-my-zsh"

# Tab completion
autoload -U  compinit
zstyle 'completion:*' menu select

# aliases
source ~/.config/zsh/.aliases

# functions
source ~/.config/zsh/.functions

# Startup operations
eval $(thefuck --alias)
neofetch