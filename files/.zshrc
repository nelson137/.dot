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
