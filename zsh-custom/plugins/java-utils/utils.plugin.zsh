jo() {
    # Java-Only
    if [[ $# != 1 ]]; then
        echo "usage: jo FILE" >&2
    else
        javac "$1"
    fi
}

jar() {
    # Java-And-Run
    if [[ $# != 1 ]]; then
        echo "usage: jar FILE" >&2
    else
        jo "$1"
        java "${1%.java}"
    fi
}

jrr() {
    # Java-Run-Remove
    if [[ $# != 1 ]]; then
        echo "usage: jrr FILE" >&2
    else
        jar "$1"
        rm "${1%.java}.class"
    fi
}
