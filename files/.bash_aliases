#!/bin/bash


aliases_f=~/.aliases
if [[ -f $aliases_f ]]; then
    source "$aliases_f"
else
    echo "Warning: $aliases_f does not exist" >&2
fi


alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
