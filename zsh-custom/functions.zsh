#!/bin/zsh

unsetopt aliases  # Turn aliases off while defining functions



bat() {
    # Get battery stats
    upower -i "$(upower -e | grep BAT)" |
        grep -E --color=never 'state|to empty|percentage'
}



chhn() {
    # Change hostname

    # Cache sudo password
    sudo echo >/dev/null

    # Exit if password not cached
    [[ $? != 0 ]] &&
        return 1

    local old="$(hostname)"
    local new; read -r 'new?New hostname: '

    # Change hostname
    echo "$new" | sudo tee /etc/hostname >/dev/null
    sudo sed -i.bak "s/${old}/${new}/g" /etc/hosts

    # Vim new and old /etc/hosts file
    # Prompt to delete old on exit
    local cmd1='autocmd QuitPre * call OnExitChhn()'
    sudo vim -c "$cmd1" -c 'topleft vnew /etc/hosts' /etc/hosts.bak
}



cpstat() {
    # Use rsync to cp and show progress
    rsync -r --info=progress2 "$@"
}



dc() {
    # Execute arguments completely disconnect from this terminal
    nohup "$@" &>!/dev/null &!
}



force_wifi() {
    # Open http site to force WAP portal redirect
    dc xdg-open 'http://icanhazip.com'
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



gl() {
    # Pull and update pull/diverge prompt status
    git pull "$@" && (_git_pd_status >/dev/null &)
}



gp() {
    # Push and update pull/diverge prompt status
    git push "$@" && (_git_pd_status >/dev/null &)
}



getip() {
    # Get public and private ip addresses
    echo "Public:  $(curl -s http://icanhazip.com)"
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
    # if necessary
    [[ $# == 0 ]] && files=( t.sh ) || files=( $@ )
    touch $files
    for f in $files; do
        print -s "vim $f"
        if [[ $f =~ \..cpp ]]; then
            echo -ne "#include <iostream>\nusing namespace std;\n\nint" > "$f"
            echo -e " main(int argc, char** argv) {\n    return 0;\n}" >> "$f"
            vim +4 "$f"
        else
            if [[ $f =~ \..py ]]; then
                echo -e "#!/usr/bin/env python3\n\n" > "$f"
            elif [[ $f =~ \..zsh ]]; then
                echo -e "#!/bin/zsh\n\n" > "$f"
            else
                echo -e "#!/bin/bash\n\n" > "$f"
            fi
            vim + +startinsert "$f"  # "+" puts cursor at bottom of file
            chmod +x "$f"
        fi
    done
}



update() {
    # Update the dot repository or this system

    if [[ -z $1 ]]; then
        update system
        return
    fi

    case "$1" in
        dot)
            git -C ~/Projects/Git/dot pull ;;
        system)
            sudo apt update && sudo apt upgrade -y ;;
        *)
            echo "update: target not recognized: $1" >&2 ;;
    esac
}



vimrm() {
    # vim a file, prompting to rm it when the user exits
    vim -c 'set nomodifiable' -c 'autocmd QuitPre * call OnExitVimrm()' "$@"
}



setopt aliases  # Turn aliases back on
