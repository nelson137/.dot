######################################################################
# Programs
######################################################################

# Homebrew
if command -v arch &>/dev/null && [[ $(arch) == arm64 ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

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
excludes="$(for d in $excludes; do printf "--exclude $d "; done)"
export FZF_CTRL_T_COMMAND="fd --type f --hidden $excludes"
unset excludes

# Less
LESSHISTFILE="$HOME/.local/cache/lesshst"

######################################################################
# System
######################################################################

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if command -v nvim &>/dev/null; then
    export EDITOR=nvim
fi

# Fix zsh-autosuggestions plugin coloring in tmux
export TERM=xterm-256color

export PAGER='less -XF'

path_prepend=(
    "$HOME"/bin
    "$HOME"/{.local,.cargo,.bun,go}/bin
    '/mnt/c/Program Files/Oracle/VirtualBox'
)
export PATH="${(j/:/)path_prepend}:$PATH"
unset path_additions

export DYLD_LIBRARY_PATH="$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH"
