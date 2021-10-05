# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Defaults
export EDITOR=/usr/bin/micro
export PATH=$PATH:/home/snow/.cargo/bin/tectonic
export ZSH="/home/snow/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Plugins
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source $HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_THEME="powerlevel10k/powerlevel10k"

# Tab completion
autoload -U  compinit
zstyle 'completion:*' menu select

# Aliases
alias colours='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done'
alias ls='ls -a'
alias rec="simplescreenrecorder"

# Quick Editing
alias e-bashrc='micro ~/.bashrc'
alias e-bspwmrc='micro ~/.config/bspwm/bspwmrc'
alias e-polybar='micro ~/.config/polybar/config.ini'
alias e-sxhkdrc='micro ~/.config/sxhkd/sxhkdrc'
alias e-zshrc='micro ~/.zshrc'

# Quick Sourcing
alias s-omz="source $ZSH/oh-my-zsh.sh"

# Functions
colour() {
    perl -e 'foreach $a(@ARGV){print "\e[48:2::".join(":",unpack("C*",pack("H*",$a)))."m \e[49m "};print "\n"' "$@"
}
pm() {
    sudo pacman "$@"
}
pdf() {
    firejail mupdf "$@"
}
transfer() {
    curl -F"file=@"${@}"" https://ttm.sh;
}
weather() {
    curl wttr.in/"$@";
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Startup operations
eval $(thefuck --alias)
neofetch