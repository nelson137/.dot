#!/bin/zsh

unsetopt aliases  # Turn aliases off while defining functions



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



ckeys() {
    # Run xev but show only key presses
    local regex='^.+(keycode) ([0-9]+) \((keysym) ([^,]+), ([^\)]+)\).+$'
    local replace='key: \5   \1: \2   \3: \4'
    xev -event keyboard | sed -rn "/keysym/ s/$regex/$replace/p"
}



cpstat() {
    # Use rsync to cp and show progress
    rsync -r --info=progress2 "$@"
}



dc() {
    # Execute arguments completely disconnect from this terminal
    nohup "$@" &>/dev/null &!
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



swap() {
    # Swap the names of 2 files or directories
    swap_err() { echo "$1" >&2; exit 1 }

    (( $# != 2 )) && echo "Usage: swap {file or dir} {file or dir}"
    [[ ! -e "$1" ]] && swap_err "swap: file or directory does not exists: $1"
    [[ ! -e "$2" ]] && swap_err "swap: file or directory does not exists: $2"
    [[ ! -w "$1" ]] && swap_err "swap: permission denied: $1"
    [[ ! -w "$2" ]] && swap_err "swap: permission denied: $2"
    local name1="$1"
    local name2="$2"
    local tmp_name="swap_tmp.$$"
    mv "$1" "$tmp_name"
    mv "$2" "$1"
    mv "$tmp_name" "$2"
}



vimrm() {
    # vim a file, prompting to rm it when the user exits
    vim -c 'set nomodifiable' -c 'autocmd QuitPre * call OnExitVimrm()' "$@"
}



setopt aliases  # Turn aliases back on
