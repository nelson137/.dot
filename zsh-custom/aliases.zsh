#!/bin/zsh

D='DISPLAY=:0'

# Command aliases
alias bc='bc -ql'
alias cp='cp -ir'
alias du='du -h --max-depth=1'
alias grep='grep -E'
alias less='less -c'
alias md='mkdir -p'
alias mkx='chmod +x'
alias mv='mv -i'
alias pdflatex='pdflatex -file-line-error'
alias pip='pip3'
alias play='dc play'
alias python='python3'
alias rm='rm -r'
alias sqlite3='sqlite3 -header -column'
alias wget='wget --hsts-file /dev/null'
alias whois='whois -H'

# apt aliases
alias -g aud='apt update'
alias -g aug='apt upgrade -y'
alias -g ai='apt install -y'

# ls aliases
os="$(uname -s)"
case "$os" in
    Linux*)
        color='--color'
        time='--time-style=long-iso'
        groupdirs='--group-directories-first' ;;
    Darwin*)
        color='-G'
        time=''
        groupdirs='' ;;
esac
alias ls="ls -pv $color $time $groupdirs"
alias la="ls -pAv $color $time $groupdirs"
alias ll="ls -pohv $color $time $groupdirs"
alias lla="ls -pAohv $color $time $groupdirs"

# git aliases
alias glop='git log -p'
alias gcam='git add -A; git commit -m'
alias gcam!='git add -A; git commit -v --amend'
alias gp='git push'
alias gsa='git submodule add --depth 1'
alias gstu='git stash push'
alias gsu='git submodule update --init --recursive --depth 1'

# My aliases
alias aliases='vim ~/.dot/zsh-custom/aliases.zsh'
alias dot='cd ~/.dot'
alias funcs='vim ~/.dot/zsh-custom/functions.zsh'
alias r='exec zsh'
alias rainbow='cat /dev/urandom | base64 | figlet -ctf term | lolcat -fad 1 -s 75 -p 5'
alias socwd='command du -csh . | tail -1'
alias setbg="$D nitrogen --set-zoom-fill --random ~/.xmonad/backgrounds/"
alias vimrc='vim ~/.vimrc'
alias wifi='nohup nm-connection-editor &>/dev/null &!'
alias zshhist='vim ~/.zsh_history'
alias zshenv='vim ~/.zshenv'
alias zshrc='vim ~/.zshrc'

# System-specific aliases
if [[ -d /mnt/c/Users/nelson ]]; then
    alias desktop='/mnt/c/Users/nelson/Desktop'
else
    alias desktop='~/Desktop'
fi

# Unaliases
unalias gcl  # From ~/.oh-my-zsh/plugins/git
unalias l  # From ~/.oh-my-zsh/lib/directories.zsh
unalias sp  # From ~/.oh-my-zsh/plugins/web-search
