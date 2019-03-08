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
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

source $ZSH/oh-my-zsh.sh

# C flags
export C_INCLUDE_PATH=/usr/include/json-c:$(py_include):~/.include/c
export CPLUS_INCLUDE_PATH=~/.include/cpp
# Static libraries (*.a)
export LIBRARY_PATH=~/.lib/c:~/.lib/cpp
# Dynamic libraries (*.so)
export LD_LIBRARY_PATH=

# gcc -l flags for the c-utils plugin
c_search_libs=(
    -lm
    $(is_mu || echo '-ljson-c')
    $(pkg-config --libs-only-l python3 2>/dev/null)
    $(pkg-config --cflags --libs-only-l gtk+-2.0 2>/dev/null)
    -lmylib
)
export C_SEARCH_LIBS="${(j: :)c_search_libs}"
export CPLUS_SEARCH_LIBS=-lmylib++

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

# Change what characters are considered a word
my-backward-delete-word () {
    local WORDCHARS='&*|'
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

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
