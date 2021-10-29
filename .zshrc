# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh