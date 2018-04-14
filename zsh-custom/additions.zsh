#!/bin/zsh

 ############
### Config ###
 ############

export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts



 #############
### Aliases ###
 #############

alias python='python3'
alias pip='pip3'

alias ls='ls -pv --color'
alias la='ls -pAv --color'
alias ll='ls -pohv --color'
alias lla='ls -pAohv --color'

alias cp="cp -ir"
alias du="du -h --max-depth=1"
alias md="mkdir -p"
alias mv="mv -i"
alias rm="rm -r"

alias update-system='sudo apt update && sudo apt upgrade -y'
alias update-dot='cd ~/Projects/Git/dot && git pull && cd -'



 ###############
### Functions ###
 ###############

mkcd() {
        eval "mkdir $1 && cd $1"
}

bat() {
    local stats="$(upower -i "$(upower -e | grep BAT)" | sed 's/^\s\+//g')"
    echo "$stats" | grep --color=never -E "state|to empty|percentage"
}

brightness() {
    if [[ $# == 0 ]]; then
        eval "xrandr --verbose | grep -i brightness | awk '{print \$2}'"
        return
    fi

    local cmd="xrandr --output eDP-1 --brightness"
    if [[ $1 == reset ]]; then
        eval "$cmd 1.0"
    else
        eval "$cmd $1 >/dev/null 2>&1" || {
            echo "Cannot set brightness to $1" >&2
            return 1
        }
    fi
}
