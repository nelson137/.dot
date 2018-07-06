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
