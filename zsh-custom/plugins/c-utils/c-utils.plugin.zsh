#!/bin/zsh


no_ext() {
    command sed -r 's/\.(c|cpp)$//' <<< "$1"
}


# Compile only
c() {
    if [[ $# != 1 ]]; then
        echo 'Usage: c <file>' >&2
        return 1
    fi

    if [[ "${1%.cpp}" != "$1" ]]; then
        g++ -std=c++11 "$1" -o "$(no_ext "$1")"
    elif [[ "${1%.c}" != "$1" ]]; then
        gcc -std=gnu11 -O3 -lm -Wall -Werror "$1" -o "$(no_ext "$1")"
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

    # Surround each exec arg with single quotes if there are any args
    exec_args="$@[2,$#]"
    (( $# > 1 )) &&
        exec_args="'${(j:' ':)exec_args}'"

    c "$1" && eval "./$(no_ext "$1") $exec_args"
}


# Compile, Execute, Remove
cer() {
    if [[ $# == 0 ]]; then
        echo 'Usage: cer <file> [<execution args> ...]' >&2
        return 1
    fi

    ce "$1" "$@[2,$#]"; rm -f "./$(no_ext "$1")"
}
