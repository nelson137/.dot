#!/bin/bash

while read -r alias_entry; do
    # echo "$alias_entry"; break
    eval "alias $alias_entry" 2>/dev/null
done < <(zsh -c '. ~/.oh-my-zsh/oh-my-zsh.sh; . ~/.zshrc; alias')
