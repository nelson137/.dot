#!/bin/zsh

D='DISPLAY=:0'

# Command aliases
alias bc='bc -ql'
alias cp='cp -r'
alias du='du -h'
alias less='less -c'
alias md='mkdir -p'
alias mv='mv -i'
alias pdflatex='pdflatex -file-line-error'
alias sqlite3='sqlite3 -header -column'
alias wget='wget --hsts-file /dev/null'
alias whois='whois -H'

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
alias ll="ls -plhv $color $time $groupdirs"
alias lla="ls -pAlhv $color $time $groupdirs"
alias lld="ls -lhdv $color $time"

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
alias socwd='command du -csh . | tail -1'
alias setbg="nitrogen --set-zoom-fill --random ~/.config/i3/assets/backgrounds"
alias vimrc='vim ~/.vimrc'
alias wifi='nohup nm-connection-editor &>/dev/null &!'
alias zathura='zathura --fork'
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
