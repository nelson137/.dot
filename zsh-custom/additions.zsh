#!/bin/zsh

ls_mac() {
    alias -g ls='ls -Gp'
    alias -g la='ls -GpA'
    alias -g ll='ls -Gpoh'
    alias -g lla='ls -GpAoh'
}

ls_linux() {
    alias -g ls='ls -p --color'
    alias -g la='ls -pA --color'
    alias -g ll='ls -poh --color'
    alias -g lla='ls -pAoh --color'
}



### Functions ###

mkcd() {
    if [[ $# != 1 ]]; then
        echo "Usage: mkcd DIR"
    else
        mkdir -p "$1" && cd -P "$1"
    fi
}

clera() {
    choices=(banner digital standard)
    i=$(( $RANDOM % ${#choices[@]} ))
    figlet -f ${choices[$i]} clera
}

call_instructs() { echo "Call in the same directory as FILE"; }

bo() {
    # Build-Only
    if [[ $# != 1 ]]; then
        echo "Usage: bo FILE" && call_instructs
    else
        g++ "$1" -std=c++11 -o "${1%.cpp}"
    fi
}

bar() {
    # Build-And-Run
    if [[ $# == 0 ]]; then
        echo "Usage: bar FILE" && call_instructs
    else
        fn="$1"
        shift
        bo "$fn" && "./${fn%.cpp}" "$@"
    fi
}

brr() {
    # Build-Run-Remove
    if [[ $# == 0 ]]; then
        echo "Usage: brr FILE" && call_instructs
    else
        fn="$1"
        shift
        bar "$fn" "$@" && rm "./${fn%.cpp}"
    fi
}

jo() {
    # Java-Only
    if [[ $# != 1 ]]; then
        echo "Usage: jo FILE" && call_instructs
    else
        javac "$1"
    fi
}

jar() {
    # Java-And-Run
    if [[ $# != 1 ]]; then
        echo "Usage: jar FILE" && call_instructs
    else
        jo "$1"
        java "${1%.java}"
    fi
}

jrr() {
    # Java-Run-Remove
    if [[ $# != 1 ]]; then
        echo "Usage: jrr FILE" && call_instructs
    else
        jar "$1"
        rm "${1%.java}.class"
    fi
}



### Setup ###

os="$(uname)"
if [[ $os == Linux ]]; then
    ls_linux
    [[ $(uname -n) == glenn-liveconsole3 ]] &&
        source "$HOME/.virtualenvs/Py3/bin/activate"
elif [[ $os == Darwin ]]; then
    ls_mac
elif [[ $os == Cygwin ]]; then
    ls_linux
fi
