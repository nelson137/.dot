#!/bin/zsh

D='DISPLAY=:0'

# Command aliases
alias bc='bc -ql'
alias du='du -h'
alias less='less -c'
alias md='mkdir -p'
alias mv='mv -i'
alias pdflatex='pdflatex -file-line-error'
alias sqlite3='sqlite3 -header -column'
alias wget='wget --hsts-file /dev/null'
alias whois='whois -H'

# ls aliases
ls="/bin/ls -vhp"
case "$(uname -s)" in
    Linux*) ls="$ls --color=auto --time-style=long-iso --group-directories-first" ;;
    Darwin*) ls="$ls -G" ;;
esac
alias ls="$ls"
alias la="$ls -A"
alias ll="$ls -l"
alias lla="$ls -lA"
alias lld="$ls -ld"

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
