#!/bin/zsh


# Compile only
c() {
    if [[ $# != 1 ]]; then
        echo 'Usage: c <file>' >&2
        return 1
    fi

    if [[ "${1%.cpp}" != "$1" ]]; then
        g++ -std=c++11 "$1" -o "${1%.cpp}"
    elif [[ "${1%.c}" != "$1" ]]; then
        gcc -std=c11 -O3 -lm -Wall -Werror "$1" -o "${1%.c}"
    else
        echo "File extension not recognized: $1" >&2
        return 1
    fi
}


# Compile and Execute
ce() {
    if [[ $# == 0 ]]; then
        echo 'Usage: ce <file> [<execution args> ...]' >&2
        return 1
    fi

    c "$1" && eval "./$(sed -r 's/\.(c|cpp)$//' <<< "$1") $@[2,$#]"
}


# Compile, Execute, Remove
cer() {
    if [[ $# == 0 ]]; then
        echo 'Usage: cer <file> [<execution args> ...]' >&2
        return 1
    fi

    ce "$1" "$@[2,$#]"; rm -f "./$(sed -r 's/\.(c|cpp)$//' <<< "$1")"
}
