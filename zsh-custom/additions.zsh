#!/bin/zsh

### Config ###

# Fix nice error
unsetopt BG_NICE

# awscli completions
[[ -d /opt/aws-cli ]] && source /opt/aws-cli/bin/aws_zsh_completer.sh

# Don't eat preceding space when | is typed
export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts

# Create vim undodir if it doesn't exist
[[ ! -d ~/.vim/undodir ]] && mkdir -p ~/.vim/undodir



### Aliases ###

# git aliases
alias glop='git log -p'
alias gc='git commit'
alias gcam='git add -A; git commit -m'

# ls aliases
alias ls='ls -pv --color'
alias la='ls -pAv --color'
alias ll='ls -pohv --color'
alias lla='ls -pAohv --color'

# Command aliases
alias cp='cp -ir'
alias du='du -h --max-depth=1'
alias grep='grep -E'
alias md='mkdir -p'
alias mkx='chmod +x'
alias mv='mv -i'
alias pip='pip3'
alias python='python3'
alias rm='rm -r'
alias sed='sed -r'
alias whois='whois -H'

# My aliases
alias -g dot='~/Projects/Git/dot'
alias additions='vim ~/Projects/Git/dot/zsh-custom/additions.zsh'
alias socwd='command du -csh . | tail -1'
alias update-dot='git -C ~/Projects/Git/dot pull'
alias update-system='sudo apt update && sudo apt upgrade -y'
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'

# System-specific aliases
if [[ -d /mnt/c/Users/nelson ]]; then
    alias desktop='/mnt/c/Users/nelson/Desktop'
else
    alias desktop='~/Desktop'
fi

# Unaliases
unalias gcl  # From ~/.oh-my-zsh/plugins/git
unalias gl  # From ~/.oh-my-zsh/plugins/git
unalias gp  # From ~/.oh-my-zsh/plugins/git
unalias l  # From ~/.oh-my-zsh/lib/directories.zsh



### Functions ###

unsetopt aliases  # Turn aliases off while defining functions

bat() {
    # Get battery stats
    upower -i "$(upower -e | grep BAT)" |
        grep -E --color=never 'state|to empty|percentage'
}

brightness() {
    # Get or set brightness of primary display

    if [[ $# == 0 ]]; then
        # Output current brightness
        xrandr -d :0 --verbose | awk '/Brightness/ {print $2}'
        return
    fi

    local cmd='xrandr -d :0 --output eDP-1 --brightness'
    if [[ $@ == reset ]]; then
        eval "$cmd 1.0"
    else
        # >&! redirects stdout and stderr
        eval "$cmd $@ >&!/dev/null" || {
            echo "Cannot set brightness to $@" >&2
            return 1
        }
    fi
}

chhn() {
    # Change hostname
    sudo echo >/dev/null  # Cache sudo password
    [[ $? != 0 ]] && return  # Exit if password not cached
    local old="$(hostname)"
    local new; read -r 'new?New hostname: '
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

ps() {
    # Remove 1 line containing "grep -E " from ps output so that
    #  `ps aux | grep ...` can be run without seeing the grep call in
    #  the ps output
    command ps "$@" | grep -m 1 -v 'grep -E '
}

vimrm() {
    # vim a file, prompting to rm it when the user exits
    vim -c 'set nomodifiable' -c 'autocmd QuitPre * call OnExitVimrm()' "$@"
}

setopt aliases  # Turn aliases back on
