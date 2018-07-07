#!/bin/bash

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

# ls aliases
alias ls='ls -pv --color'
alias la='ls -pAv --color'
alias ll='ls -pohv --color'
alias lla='ls -pAohv --color'

# git aliases
alias g='git'
alias ga='git add'
alias gapa='git add --patch'
alias gc='git commit'
alias gc!='git commit -v --amend'
alias gcam='git add -A; git commit -m'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias glop='git log -p'
alias gc='git commit'
alias gcam='git add -A; git commit -m'
alias gcmsg='git commit -m'
alias gd='git diff'
alias gdca='git diff --cached'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grbs='git rebase --skip'
alias grh='git reset'
alias grhh='git reset --hard'
alias gst='git status'

# My aliases
alias additions='vim ~/Projects/Git/dot/zsh-custom/additions.zsh'
alias dot='~/Projects/Git/dot'
alias r='exec bash'
alias rainbow='cat /dev/urandom | base64 | figlet -ctf term | lolcat -fad 1 -s 75 -p 5'
alias socwd='command du -csh . | tail -1'
# alias suspend='sudo systemctl suspend'
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'

# System-specific aliases
if [[ -d /mnt/c/Users/nelson ]]; then
    alias desktop='/mnt/c/Users/nelson/Desktop'
else
    alias desktop='~/Desktop'
fi
