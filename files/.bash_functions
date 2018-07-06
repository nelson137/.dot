#!/bin/bash



clera() {
    choices=(banner digital standard)
    i=$(( $RANDOM % ${#choices[@]} ))
    figlet -f ${choices[$i]} clera
}



bo() {
    # Build Only
    if [[ $# != 1 ]]; then
        echo 'Usage: bo <file>' >&2
        return 1
    else
        g++ "$1" -std=c++11 -o "${1%.cpp}"
    fi
}



bar() {
    # Build And Run
    if [[ $# == 0 ]]; then
        echo 'Usage: bar <file> [<execution args> ...]' >&2
        return 1
    else
        src="$1"
        shift
        bo "$src" && "./${src%.cpp}" "$@"
    fi
}



brr() {
    # Build, Run, Remove
    if [[ $# == 0 ]]; then
        echo 'Usage: brr <file> [<execution args> ...]' >&2
        return 1
    else
        src="$1"
        shift
        bar "$src" "$@" && rm "./${src%.cpp}"
    fi
}



jo() {
    # Java Only
    if [[ $# != 1 ]]; then
        echo 'Usage: jo <file>' >&2
        return 1
    else
        javac "$1"
    fi
}



jar() {
    # Java And Run
    if [[ $# != 1 ]]; then
        echo 'Usage: jar <file>' >&2
        return 1
    else
        jo "$1" && java "${1%.java}"
    fi
}



jrr() {
    # Java, Run, Remove
    if [[ $# != 1 ]]; then
        echo 'Usage: jrr <file>' >&2
        return 1
    else
        jar "$1" && rm "${1%.java}.class"
    fi
}



mkcd() {
    if [[ $# != 1 ]]; then
        echo 'Usage: mkcd DIR'
    else
        mkdir -p "$1" && cd -P "$1"
    fi
}
