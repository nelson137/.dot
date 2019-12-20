#!/bin/bash

here="$(cd "$(dirname "$0")" && pwd)"

listdir() {
    find "$1" -maxdepth 1 | sed 1d
}

# Clone all submodules
git submodule update --init --recursive

# Link config files
listdir "$here/files" | xargs -I % ln -fs % "$HOME"

# Make ~/.config a directory if it isn't one/doesn't exist
[ ! -d "$HOME/.config" ] && { rm -f "$HOME/.config"; mkdir "$HOME/.config"; }
# Link config directories
listdir "$here/.config" | xargs -I % ln -fs % "$HOME/.config"

# Link vim autoload files
mkdir -p "$HOME/.vim/autoload"
ln -fs "$here/.vim/autoload/"* "$HOME/.vim/autoload"

# Install repository hooks
"$here/install-hooks.sh"

# Install fzf
"$here/components/fzf/install" --bin --64
