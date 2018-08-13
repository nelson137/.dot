#!/bin/zsh

# Command aliases
alias cp='cp -ir'
alias du='du -h --max-depth=1'
alias feh='DISPLAY=:0 feh -x.'
alias grep='grep -E'
alias md='mkdir -p'
alias mkx='chmod +x'
alias mv='mv -i'
alias pip='pip3'
alias play='dc play'
alias python='python3'
alias rm='rm -r'
alias sed='sed -r'
alias whois='whois -H'

# ls aliases
alias ls='ls -pv --color --time-style=long-iso'
alias la='ls -pAv --color --time-style=long-iso'
alias ll='ls -pohv --color --time-style=long-iso'
alias lla='ls -pAohv --color --time-style=long-iso'

# git aliases
alias glop='git log -p'
alias gcam='git add -A; git commit -m'

# My aliases
alias aliases='vim ~/Projects/Git/dot/zsh-custom/aliases.zsh'
alias dot='cd ~/Projects/Git/dot'
alias funcs='vim ~/Projects/Git/dot/zsh-custom/functions.zsh'
alias r='exec zsh'
alias rainbow='cat /dev/urandom | base64 | figlet -ctf term | lolcat -fad 1 -s 75 -p 5'
alias socwd='command du -csh . | tail -1'
alias setbg='DISPLAY=:0 nitrogen --set-zoom-fill --random ~/.xmonad/backgrounds/'
alias vimrc='vim ~/.vimrc'
alias zshhist='vim ~/.zsh_history'
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
