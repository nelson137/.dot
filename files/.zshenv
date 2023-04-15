###################
### Environment ###
###################

path_=(
    "$HOME"/bin{,/compiled}
    "$HOME"/{.local,.cargo,.dot/components/fzf,go}/bin
    '/mnt/c/Program Files/Oracle/VirtualBox'
)
export PATH="${(j/:/)path_}:$PATH"
unset path_

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR=vim

# Fix zsh-autosuggestions plugin coloring in tmux
export TERM=xterm-256color

#################
### My Config ###
#################

export PYTHONSTARTUP="$HOME/.pythonrc"
export PYTHONDONTWRITEBYTECODE=1

# Give vagrant access to WSL features
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts

# fzf
excludes=(.cache .npm .gem .vim/undodir)
excludes='--exclude '${^excludes}
export FZF_CTRL_T_COMMAND="fd --type f --hidden $excludes"
unset excludes
