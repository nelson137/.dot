#!/bin/zsh

ls_mac() {
    alias -g ls='ls -Gp'
    alias -g la='ls -GpA'
    alias -g ll='ls -Gpoh'
    alias -g lla='ls -GpAoh'
}

ls_linux() {
    alias -g ls='ls -p --color'
    alias -g la='ls -pA --color'
    alias -g ll='ls -poh --color'
    alias -g lla='ls -pAoh --color'
}
