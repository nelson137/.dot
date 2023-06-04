######################################################################
# Programs
######################################################################

# Cargo
[[ -d "$HOME/.cargo" ]] && source "$HOME/.cargo/env"

# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1

# Vagrant
# Give vagrant access to WSL features
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts

# FZF
excludes=(.cache .npm .gem .vim/undodir)
excludes='--exclude '${^excludes}
export FZF_CTRL_T_COMMAND="fd --type f --hidden $excludes"
unset excludes

######################################################################
# System
######################################################################

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR=vim

# Fix zsh-autosuggestions plugin coloring in tmux
export TERM=xterm-256color

path_prepend=(
    "$HOME"/bin
    "$HOME"/{.local,.cargo,.bun,go}/bin
    '/mnt/c/Program Files/Oracle/VirtualBox'
)
export PATH="${(j/:/)path_prepend}:$PATH"
unset path_additions

export DYLD_LIBRARY_PATH="$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH"
