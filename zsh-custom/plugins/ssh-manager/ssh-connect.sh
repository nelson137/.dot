#!/bin/bash

ssh-connect() {
    local hist=$(ssh-history | tr '\n' '|')
    res=$(listbox -t "Connect:" -o "$hist" | tee /dev/tty | tail -n 1)
    echo ""
    echo "$res" >> "$HISTFILE"
    eval "$res"
}
