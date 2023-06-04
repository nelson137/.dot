#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

ln_dir_contents() {
    # Make sure src and dest are absolute dir paths
    local src="$(cd "$1" && pwd)"
    local dest="$(cd "$2" && pwd)"
    # Link files
    find "$src" -mindepth 1 -maxdepth 1 -exec ln -fst "$dest" '{}' \+
}

mkdir -p "$HOME/bin"

# Clone all submodules
git submodule update --init --recursive

# Link config files
ln_dir_contents files "$HOME"

# Link config directories
declare -a CONFIG_ITEMS
CONFIG_ITEMS=(nvim)
case "$(uname -s)" in
    Darwin)
        CONFIG_ITEMS+=()
        ;;
    Linux)
        CONFIG_ITEMS+=(compton.conf i3 zathura)
        ;;
esac
ln_dir_contents config "$HOME/.config"
unset CONFIG_ITEMS

# Install repository hooks
./install-hooks.sh

# Install fzf
./components/fzf/install --bin --64
ln -s "$PWD/components/fzf/bin/fzf" "$HOME/bin/fzf"
