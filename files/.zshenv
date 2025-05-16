######################################################################
# Programs
######################################################################

# Cargo
if [[ $SHLVL == 1 ]]; then
    [[ -d "$HOME/.cargo" ]] && source "$HOME/.cargo/env"
fi

# Python
[[ -f "$HOME/.pythonrc" ]] && export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHON_HISTORY="$HOME/.local/share/python/python_history"
export PYTHONDONTWRITEBYTECODE=1

# Vagrant
# Give vagrant access to WSL features
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts

# Less
LESSHISTFILE="$HOME/.local/share/less/lesshst"

######################################################################
# System
######################################################################

if command -v nvim &>/dev/null; then
    export EDITOR=nvim
fi

export PAGER='less -XF'

if [[ $SHLVL == 1 ]]; then
    path_prepend=(
        "$HOME"/{.dot,.bun,go,.local}/bin
    )
    export PATH="${(j/:/)path_prepend}:$PATH"
    unset path_additions
fi

if command -v rustc &>/dev/null; then
    export DYLD_LIBRARY_PATH="$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH"
fi
