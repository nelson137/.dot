#!/bin/zsh

 ############
### Config ###
 ############

export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'



 #############
### Aliases ###
 #############

alias python='python3'
alias pip='pip3'

alias ls='ls -pv --color'
alias la='ls -pAv --color'
alias ll='ls -pohv --color'
alias lla='ls -pAohv --color'

alias update-system='sudo apt update && sudo apt upgrade -y'
alias update-dot='cd ~/Projects/Git/dot && git pull && cd -'



 ###############
### Functions ###
 ###############

mkcd() {
    if [[ $# != 1 ]]; then
        echo "Usage: mkcd DIR"
    else
        mkdir -p "$1" && cd -P "$1"
    fi
}

clera() {
    choices=(banner digital standard)
    i=$(( $RANDOM % ${#choices[@]} + 1 ))
    figlet -f ${choices[i]} clera
}

bat() {
    BAT_STATS=$(upower -i $(upower -e | grep 'BAT'))
    echo $BAT_STATS | grep --color=never -E "state|to\ empty|percentage"
}

call_instructs() { echo "Call in the same directory as FILE"; }

bo() {
    # Build-Only
    if [[ $# != 1 ]]; then
        echo "usage: bo FILE"; call_instructs
    else
        g++ "$1" -std=c++11 -o "${1%.cpp}"
    fi
}

bar() {
    # Build-And-Run
    if [[ $# == 0 ]]; then
        echo "usage: bar FILE [ARGS]"; call_instructs
    else
        fn="$1"
        shift
        bo "$fn" && "./${fn%.cpp}" "$@"
    fi
}

brr() {
    # Build-Run-Remove
    if [[ $# == 0 ]]; then
        echo "usage: brr FILE [ARGS]"; call_instructs
    else
        fn="$1"
        shift
        bar "$fn" "$@" && rm "./${fn%.cpp}"
    fi
}

jo() {
    # Java-Only
    if [[ $# != 1 ]]; then
        echo "usage: jo FILE" && call_instructs
    else
        javac "$1"
    fi
}

jar() {
    # Java-And-Run
    if [[ $# != 1 ]]; then
        echo "usage: jar FILE" && call_instructs
    else
        jo "$1"
        java "${1%.java}"
    fi
}

jrr() {
    # Java-Run-Remove
    if [[ $# != 1 ]]; then
        echo "usage: jrr FILE" && call_instructs
    else
        jar "$1"
        rm "${1%.java}.class"
    fi
}

setup_phantomjs() {
    export QT_QPA_PLATFORM=offscreen
    export QT_QPA_FONTDIR=/usr/share/fonts
}
