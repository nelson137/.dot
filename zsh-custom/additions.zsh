#!/bin/zsh

 ############
### Config ###
 ############

# awscli completions
[[ -d /opt/aws-cli ]] && source /opt/aws-cli/bin/aws_zsh_completer.sh

# Don't eat preceding space when | is typed
export ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&'

# Phantomjs
export QT_QPA_PLATFORM=offscreen
export QT_QPA_FONTDIR=/usr/share/fonts



 #############
### Aliases ###
 #############

# ls aliases
alias ls='ls -pv --color'
alias la='ls -pAv --color'
alias ll='ls -pohv --color'
alias lla='ls -pAohv --color'

# Command aliases
alias cp="cp -ir"
alias du="du -h --max-depth=1"
alias grep='egrep'
alias md="mkdir -p"
alias mkx="chmod +x"
alias mv="mv -i"
alias rm="rm -r"
alias sed='sed -r'
alias whois='whois -H'

# My aliases
alias -g dot='~/Projects/Git/dot'
alias additions='vim ~/Projects/Git/dot/zsh-custom/additions.zsh'
alias pip='pip3'
alias python='python3'
alias update-dot='git -C ~/Projects/Git/dot pull'
alias update-system='sudo apt update && sudo apt upgrade -y'
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'

# Unaliases
unalias l  # Unalias l from .oh-my-zsh/lib/directories.zsh
unalias gcl  # Unalias gcl from .oh-my-zsh/plugins/git



 ###############
### Functions ###
 ###############

bat() {
    # Get battery stats
    local stats="$(upower -i "$(upower -e | grep BAT)" | sed 's/^\s\+//g')"
    echo "$stats" | grep --color=never -E "state|to empty|percentage"
}

brightness() {
    # Get or set screen brightness
    if [[ $# == 0 ]]; then
        xrandr --verbose | grep -i brightness | awk '{print $2}'
        return
    fi

    local cmd="xrandr --output eDP-1 --brightness"
    if [[ $1 == reset ]]; then
        eval "$cmd 1.0"
    else
        eval "$cmd $1 >/dev/null 2>&1" || {
            echo "Cannot set brightness to $1" >&2
            return 1
        }
    fi
}

chhn() {
    # Change Hostname
    sudo echo >/dev/null  # Get sudo password before changing hostname
    local old="$(hostname)"
    local new; read -rp "New hostname: " new
    echo "$new" | sudo tee /etc/hostname >/dev/null
    sed -i "s/${old}/${new}/g" /etc/hosts
}

gcl() {
    git clone --recursive "git@github.com:nelson137/$1.git"
}

getip() {
    # Get public and private ip addresses
    echo "Public:  $(curl -sS https://icanhazip.com)"
    echo "Private: $(hostname -I | awk '{print $1}')"
}

mkcd() {
        mkdir "$1" && cd "$1"
}

newscript() {
    [[ $# == 0 ]] && files=( t.sh ) || files=( $@ )
    touch $files
    for file in $files; do
        print -s "vim $file"
        if [[ $file =~ \..cpp ]]; then
            echo -ne "#include <iostream>\nusing namespace std;\n\nint" > "$file"
            echo -e " main(int argc, char** argv) {\n    return 0;\n}" >> "$file"
            vim +4 "$file"
        else
            if [[ $file =~ \..py ]]; then
                echo -e "#!/usr/bin/env python3\n\n" > "$file"
            elif [[ $file =~ \..zsh ]]; then
                echo -e "#!/bin/zsh\n\n" > "$file"
            else
                echo -e "#!/bin/bash\n\n" > "$file"
            fi
            vim + +startinsert "$file"  # "+" puts cursor at bottom of file
            chmod +x "$file"
        fi
    done
}

vimrm() {
    cmd1='set nomodifiable'
    cmd2='function! OnExit()
        let choice = confirm("Do you want to delete this file", "&yes\n&no", 2)
        if choice == 1
            silent !rm %
        endif
    endfunction'
    cmd3='autocmd VimLeavePre * call OnExit()'

    vim "$1" -c "$cmd1" -c "$cmd2" -c "$cmd3"
}
