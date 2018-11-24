#!/bin/zsh

setopt localtraps


c_no_ext() {
    sed -E 's/\.(c|cpp)$//' <<< "$1"
}


# Compile only
c() {
    if [[ $# == 0 ]]; then
        echo 'Usage: c <file>' >&2
        return 1
    fi

    local stdflags='-O3 -Wall -Werror'
    if [[ "${1%.cpp}" != "$1" ]]; then
        local cppflags="-std=c++11 $stdflags"
        eval "g++ $cppflags $1 -o '$(c_no_ext "$1")' $@[2,$#]"
    elif [[ "${1%.c}" != "$1" ]]; then
        local cflags="-std=c11 $stdflags"
        eval "gcc $cflags '$1' -o '$(c_no_ext "$1")' $C_LD_FLAGS $@[2,$#]"
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
    exec_args=( "$@[2,$#]" )
    (( $# > 1 )) &&
        exec_args="'${(j:' ':)exec_args}'"

    c "$1" && eval "$(c_no_ext "$1") $exec_args"
}


# Compile, Execute, Remove
cer() {
    if [[ $# == 0 ]]; then
        echo 'Usage: cer <file> [<execution args> ...]' >&2
        return 1
    fi

    trap "rm -f '$(c_no_ext "$1")'" EXIT INT TERM
    ce "$1" "$@[2,$#]"
}
