# If you come from bash you might have to change your $PATH.
export PATH="$HOME/bin:$HOME/bin/compiled:$HOME/.local/bin:$HOME/go/bin:/mnt/c/Program Files/Oracle/VirtualBox:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="custom"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Ignore false positive security risks with completions
export ZSH_DISABLE_COMPFIX=true

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$HOME/.dot/zsh-custom"

plugins=(
    colored-man-pages
    c-utils
    extract
    git
    git-prompt
    git-prompt-custom
    java-utils
    listbox
    web-search
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# zsh-syntax-highlighting config
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor root)

source $ZSH/oh-my-zsh.sh



### My Config ###

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EDITOR='vim'

# Fix zsh-autosuggestions plugin coloring in tmux
export TERM=xterm-256color

# C flags
pi=$(find /usr/include -maxdepth 1 -name 'python3*' | sort -n | head -1)
pi2=$(find /usr/include -maxdepth 1 -name 'python2*' | sort -n | head -1)
[[ -z $pi ]] && pi="$pi2"
export C_INCLUDE_PATH=/usr/include/json-c:$pi:~/.include
export LIBRARY_PATH=~/.lib

# gcc -l flags for the c-utils plugin
c_ld_flags=(
    -lm
    $(is_mu || echo '-ljson-c')
    -lmylib
    $(pkg-config --cflags --libs python3 2>/dev/null)
)
export C_LD_FLAGS="${(j: :)c_ld_flags}"

# Give vagrant access to WSL features
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1

# Fix nice error
unsetopt BG_NICE

# Delete duplicate history items before unique ones
setopt HIST_EXPIRE_DUPS_FIRST

# Don't add commands to history if they have a leading space
setopt HIST_IGNORE_SPACE

# echo 'ab''c'  # output: ab'c
setopt RC_QUOTES

# awscli completions
[[ -d /opt/aws-cli ]] && source /opt/aws-cli/bin/aws_zsh_completer.sh

# Don't eat preceding space when | is typed
export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts

# Create vim undodir if it doesn't exist
[[ ! -d ~/.vim/undodir ]] && mkdir -p ~/.vim/undodir

# Update ~/.aliases daily for use in bash
now="$(date +%s)"
lastrun_f=~/.bash_aliases.lastrun
[[ ! -f $lastrun_f ]] && echo "$now" > "$lastrun_f"
one_day_passed="$(( now - $(< "$lastrun_f") > 86400 ))"
if [[ ! -f $lastrun_f || ! -f ~/.aliases || $one_day_passed == 1 ]]; then
    date +%s > "$lastrun_f"
    # sed scripts:
    # - Ignore all lines starting with "-"
    # - Put "alias" in front of each line
    (alias | sed -E '/^(\-)/d; s/(.+)/alias \1/' > ~/.aliases &)
fi

true
