###################
### Environment ###
###################

export PATH="$HOME/bin:$HOME/bin/compiled:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.dot/components/fzf/bin:/mnt/c/Program Files/Oracle/VirtualBox:$PATH"

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='vim'

# Fix zsh-autosuggestions plugin coloring in tmux
export TERM=xterm-256color

#################
### My Config ###
#################

export PYTHONSTARTUP="$HOME/.pythonrc"

# Give vagrant access to WSL features
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

# Don't eat preceding space when | is typed
export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts
