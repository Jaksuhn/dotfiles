# More of a note for myself, but if this file can't be sourced citing "command not found: ^M"
# or "parse error near xxx", it's (probably) due to the script being in DOS format. Use the
# "dos2unix" package to fix, e.g. "dos2unix -f .zshrc"

# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files source by it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'yes'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# ssh when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over ssh to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Disable Tmux. Setting this during z4h setup does not put this line in here
zstyle ':z4h:' start-tmux 'no'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)
path+=/home/snow/.cargo/bin/tectonic

# Export environment variables.
export GPG_TTY=$TTY
export EDITOR=/usr/bin/micro
export SPLIT='v' # split kitty vertically

# NNN
export LC_COLLATE="C" # hidden files on top
export NNN_FIFO=/tmp/nnn.fifo
export NNN_PLUG='p:preview-tui'

# Source additional local files if they exist.
# z4h source ~/.env.zsh
z4h source ~/.config/zsh/.aliases
z4h source ~/.config/zsh/.functions

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
# z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
# z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin
z4h load ohmyzsh/ohmyzsh/plugins/command-not-found
z4h load ohmyzsh/ohmyzsh/plugins/colored-man-pages
z4h load ohmyzsh/ohmyzsh/plugins/extract
z4h load ohmyzsh/ohmyzsh/plugins/git
z4h load ohmyzsh/ohmyzsh/plugins/git-extras
z4h load ohmyzsh/ohmyzsh/plugins/universalarchive
z4h load ohmyzsh/ohmyzsh/plugins/virtualenv


# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/  # undo the last command line change
z4h bindkey redo Alt+/   # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function mkcd() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories mkcd

# Define named directories: ~w <=> Windows home directory on WSL.
# [[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Miscellaneous
fpath=(~/.config/zsh/ $fpath)

# Startup operations
eval $(thefuck --alias)
neofetch --kitty --size 25% --source ~/.config/neofetch/doge.png

# everything after this line will be removed automatically
sh ~/.config/startup/post_install.sh