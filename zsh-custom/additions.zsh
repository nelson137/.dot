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







### Setup ###

os="$(uname)"
if [[ $os == Linux ]]; then
    ls_linux
    [[ $(uname -n) == glenn-liveconsole3 ]] &&
        source "$HOME/.virtualenvs/Py3/bin/activate"
elif [[ $os == Darwin ]]; then
    ls_mac
elif [[ $os == Cygwin ]]; then
    ls_linux
fi
