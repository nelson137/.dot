######################################################################
# Programs
######################################################################

# Cargo
[[ -d "$HOME/.cargo" ]] && source "$HOME/.cargo/env"

# Python
export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHON_HISTORY="$HOME/.local/share/python/python_history"
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
export FZF_DEFAULT_COMMAND="fd --type f --hidden $excludes"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
unset excludes
export FZF_CTRL_G_COMMAND="git status --porcelain=v1 --untracked-files=all | awk '{print \$NF}'"

# Less
LESSHISTFILE="$HOME/.local/share/less/lesshst"

######################################################################
# System
######################################################################

if command -v nvim &>/dev/null; then
    export EDITOR=nvim
fi

export PAGER='less -XF'

path_prepend=(
    "$HOME"/{.local,.cargo,.bun,go}/bin
    '/mnt/c/Program Files/Oracle/VirtualBox'
)
export PATH="${(j/:/)path_prepend}:$PATH"
unset path_additions

if command -v rustc &>/dev/null; then
    export DYLD_LIBRARY_PATH="$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH"
fi
