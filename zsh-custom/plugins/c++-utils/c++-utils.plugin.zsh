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
        file="$1"
        shift
        bo "$file" && "./${file%.cpp}" $@
    fi
}

brr() {
    # Build, Run, Remove
    if [[ $# == 0 ]]; then
        echo 'Usage: brr <file> [<execution args> ...]' >&2
        return 1
    else
        file="$1"
        shift
        bar "$file" $@ && rm "./${file%.cpp}"
    fi
}
