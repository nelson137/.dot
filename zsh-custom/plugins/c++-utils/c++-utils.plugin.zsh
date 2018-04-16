bo() {
    # Build-Only
    if [[ $# != 1 ]]; then
        echo "usage: bo FILE" >&2
    else
        g++ "$1" -std=c++11 -o "${1%.cpp}"
    fi
}

bar() {
    # Build-And-Run
    if [[ $# == 0 ]]; then
        echo "usage: bar FILE [ARGS]" >&2
    else
        fn="$1"
        shift
        bo "$fn" && "./${fn%.cpp}" "$@"
    fi
}

brr() {
    # Build-Run-Remove
    if [[ $# == 0 ]]; then
        echo "usage: brr FILE [ARGS]"; >&2
    else
        fn="$1"
        shift
        bar "$fn" "$@" && rm "./${fn%.cpp}"
    fi
}
