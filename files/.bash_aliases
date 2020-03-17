# vim: ft=bash

aliases_f="$HOME/.aliases"
[ -f "$aliases_f" ] && source "$aliases_f"

# cd ancestor
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
