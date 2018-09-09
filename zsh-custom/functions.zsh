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



is_wsl() {
    grep -qE '(Microsoft|WSL)' /proc/version 2>/dev/null
}



mc() {
    # Make then cd into a directory
    mkdir -p "$@" && eval "cd \$$#"
}



newscript() {
    # Make a new script with boilerplate code and executable if necessary
    [[ $# == 0 ]] && files=( t.sh ) || files=( $@ )
    for f in $files; do
        if [[ -e $f ]]; then
            echo "script already exists: $f" >&2
            continue
        fi

        touch "$f"
        print -s "vim $f"
        if [[ $f =~ .+[.]c$ ]]; then
            cat <<'EOF' > "$f"
#include <stdio.h>

int main(void) {

    return 0;
}
EOF
            vim +3 "$f"
        elif [[ $f =~ .+[.]cpp$ ]]; then
            cat <<'EOF' > "$f"
#include <iostream>
using namespace std;

int main(int argc, char** argv) {

    return 0;
}
EOF
            vim +4 "$f"
        elif [[ $f =~ .+[.]py$ ]]; then
            cat <<'EOF' > "$f"
#!/usr/bin/env python3

"""Test."""



EOF
            vim + +startinsert "$f"  # "+" puts cursor at bottom of file
            chmod +x "$f"
        elif [[ $f =~ .+[.]zsh$ ]]; then
            echo '#!/bin/zsh\n\n\n' > "$f"
            vim + +startinsert "$f"
            chmod +x "$f"
        else
            echo '#!/bin/bash\n\n\n' > "$f"
            vim + +startinsert "$f"
            chmod +x "$f"
        fi
    done
}



ping() {
    if [[ $# == 1 ]]; then
        if [[ $1 == gateway ]]; then
            # Ping the default gateway if the only argument is "gateway"
            command ping $(ip route | awk '/default/ {print $3}')
            return 0
        else
            # Ping the given host 3 times
            command ping "$1" -c 3
            return 0
        fi
    fi

    # Run ping with the passed arguments
    command ping "$@"
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
