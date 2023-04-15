#!/bin/bash

# unsetopt aliases  # TODO: Turn aliases off while defining functions



bat() {
    # Get battery stats
    upower -i "$(upower -e | grep BAT)" |
        grep -E --color=never 'state|to empty|percentage'
}



cpstat() {
    # Use rsync to cp and show progress
    rsync -r --info=progress2 "$@"
}



dc() {
    nohup "$@" &>/dev/null & disown
}



gcl() {
    # git clone username/repo(.git) or repo(.git)
    # In the case without a username, it's assumed the repo is mine
    local repo="${1%.git}"
    if [[ $repo =~ ^.*/$ || $repo =~ ^/.+$ ]]; then
        # Invalid repo names:
        #  abc/
        #  /abc
        #  /
        echo "invalid repo name: $repo" >&2
    elif [[ $repo =~ .+/.+ ]]; then
        # Clone someone else's repo
        git clone --recursive "https://github.com/${repo}.git"
    else
        # Clone my repo
        git clone --recursive "git@github.com:nelson137/${repo}.git"
    fi
}



getip() {
    # Get public and private ip addresses
    echo "Public:  $(curl -s https://icanhazip.com)"
    local private_ip="$(
        ip route get 1 |
        grep -oE '192\.168(\.[0-9]{1,3}){2}' |
        grep -v '^192\.168\.1\.1$'
    )"
    echo "Private: $private_ip"
}



mkcd() {
    # Make then cd into a directory
    mkdir "$1" && cd "$1"
}



newscript() {
    # Make a new script with boilerplate code and make it executable
    #  if necessary
    [[ $# == 0 ]] && files=( t.sh ) || files=( "$@" )
    touch "${files[@]}"
    for f in "${files[@]}"; do
        # TODO: translate to bash
        # print -s "vim $f"
        if [[ "$f" =~ \..cpp ]]; then
            echo -ne "#include <iostream>\nusing namespace std;\n\nint" > "$f"
            echo -e " main(int argc, char** argv) {\n    return 0;\n}" >> "$f"
            vim +4 "$f"
        else
            if [[ "$f" =~ \..py ]]; then
                echo -e "#!/usr/bin/env python3\n\n" > "$f"
            elif [[ "$f" =~ \..zsh ]]; then
                echo -e "#!/bin/zsh\n\n" > "$f"
            else
                echo -e "#!/bin/bash\n\n" > "$f"
            fi
            vim + +startinsert "$f"  # "+" puts cursor at bottom of file
            chmod +x "$f"
        fi
    done
}



ps() {
    # Remove 1 line containing "grep -E " from ps output so that
    # `ps aux | grep ...` can be run without seeing the grep call in
    # the ps output
    command ps "$@" | grep -Evm 1 'grep -E '
}



update() {
    if [[ -z "$1" ]]; then
        update system
        return
    fi

    case "$1" in
        dot)
            git -C ~/.dot/pull ;;
        system)
            sudo apt update && sudo apt upgrade -y ;;
        *)
            echo "target not recognized: $1" >&2 ;;
    esac
}



# setopt aliases  # TODO: Turn aliases back on
