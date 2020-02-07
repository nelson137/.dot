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
    xev -event keyboard | sed -En "/keysym/ s/$regex/$replace/p"
}



cp() {
    local dryrun=0

    local srcs=()
    for arg in "$@"; do
        case "$arg" in
            # Ignore extra recursive option
            -r|--recursive) ;;

            # Print the command what would be executed
            -d|--dry-run) dryrun=1 ;;

            # Call cp if there are any unrecognized options
            -*) /bin/cp "$@"; return ;;

            # Add positional args to srcs
            *) srcs+=( "$arg" ) ;;
        esac
    done

    # At least 2 positional arguments are required
    [ "$#srcs" -lt 2 ] && return 1

    set -o pipefail
    # Get total size of all srcs except the last (it's the dest)
    size="$(/usr/bin/du -scLB 1 "${(@)srcs[1,-2]}" | awk '{s=$1}END{print s}')"
    # Exit if du fails to stat any file or dir
    [ $? -eq 0 ] || return

    local cmd=()
    # If size < 250MB
    if (( size < 250*1024*1024 )); then
        cmd=( /bin/cp -r )
    else
        cmd=( /usr/bin/rsync -rP )
    fi

    if [ "$dryrun" -eq 1 ]; then
        echo "${cmd[@]}" "$@"
    else
        eval "${cmd[@]}" "$@"
    fi
}



diff() {
    git diff --no-index -- "$@"
}



feh() {
    DISPLAY=:0 /usr/bin/feh --scale-down -x "$@" &>/dev/null &|
}



file_birth() {
    inode="$(stat -c %i "$1")"
    dev="$(df --output=source "$1" | tail -1)"
    sudo debugfs -R "stat <$inode>" "$dev" \
      | grep crtime \
      | cut -d ' ' -f 4-
}



force_wifi() {
    # Open http site to force WAP portal redirect
    xdg-open 'https://google.com' &>/dev/null &|
}



gcl() {
    clone() { git clone --recurse-submodules -j8 "$@"; }
    # git clone username/repo(.git) or repo(.git)
    # In the case without a username, it's assumed the repo is mine
    for name in "$@"; do
        local repo="${name%.git}"
        if [[ $repo =~ ^.*/$ || $repo =~ ^/.+$ ]]; then
            # Invalid repo names:
            #  abc/
            #  /abc
            #  /
            echo "invalid repo name: $repo" >&2
        elif [[ $repo =~ .+/.+ ]]; then
            # Clone someone else's repo
            clone "https://github.com/${repo}.git"
        else
            # Clone my repo
            clone "git@github.com:nelson137/${repo}.git"
        fi
    done
}



is_mu() {
    [[ "$(hostname)" =~ tc-m[0-9]+-(login|hpc[0-9]+)-node[0-9]+ ]]
}



is_wsl() {
    grep -qE '(Microsoft|WSL)' /proc/version 2>/dev/null
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
#include <string>
#include <vector>

using namespace std;


int main() {

    return 0;
}
EOF
            vim +6 "$f"
        elif [[ $f =~ .+[.]py$ ]]; then
            cat <<'EOF' > "$f"
#!/usr/bin/env python3



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
    if [[ $# == 1 && "$1" == gateway ]]; then
        /bin/ping -c3 "$(ip route | awk '/default/ {print $3}')"
    else
        /bin/ping "$@"
    fi
}



py_include() {
    find_py_include() {
        find /usr/include -maxdepth 1 -name "$1" | sort -n | head -1
    }
    pi3=$(find_py_include 'python3*')
    pi2=$(find_py_include 'python2*')
    [[ -n "$pi3" ]] && echo "$pi3" || echo "$pi2"
}



xset() {
    [[ $# == 2 && $1 == q ]] || { /usr/bin/xset "$@"; return $?; }

    local setting
    case "$2" in
        keyboard) setting='Keyboard Control' ;;
        mouse)    setting='Pointer Control' ;;
        s)        setting='Screen Saver' ;;
        p)        setting='Colors' ;;
        fp)       setting='Font Path' ;;
        dpms)     setting='DPMS \(Energy Star\)' ;;
        *)        echo "xset setting not recognized: $2" >&2; return 1 ;;
    esac

    xset q | sed -E "/$setting:/,/^\\S/!d" | sed -E '$s/^(\S)/\1/;Te;d;:e'
}



setopt aliases  # Turn aliases back on
