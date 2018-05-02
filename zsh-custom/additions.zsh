#!/bin/zsh

 ############
### Config ###
 ############

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
alias additions='vim ~/Projects/Git/dot/zsh-custom/additions.zsh'
alias dot='cd ~/Projects/Git/dot'
alias pip='pip3'
alias python='python3'
alias update-dot='git -C ~/Projects/Git/dot pull'
alias update-system='sudo apt update && sudo apt upgrade -y'
alias vimrc='vim ~/.vimrc'

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
        eval "xrandr --verbose | grep -i brightness | awk '{print \$2}'"
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
    printf "Private: "
    local cmd
    if (( ${+commands[ip]} )) && cmd="ip a" || cmd="ifconfig"
    eval "$cmd | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}'"
}

mkcd() {
        eval "mkdir $1 && cd $1"
}

newscript() {
    [[ $# == 0 ]] && files=( t.sh ) || files=( $@ )
    touch $files
    chmod +x $files
    for file in $files; do
        echo -e "#!/bin/bash\n\n" > $file
        print -s "vim $file"
        vim + $file  # The "+" puts cursor at bottom of file
    done
}
