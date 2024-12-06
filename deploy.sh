#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

# Usage: ln_dir_contents SRC DEST
#
# Create symbolic links in DEST for each child of SRC (non-recursive).
#
# Positional Arguments:
#   SRC     The path of the directory in which to create the symbolic links.
#   DEST    The path of the directory that contains the target files.
#
# Example:
#
#     $ ln_dir_contents ./files /tmp
#
# With files:
#
# ./files/
# ├── .bashrc
# ├── .zprofile
# └── .zshrc
#
# Creates symbolic links:
#
# /tmp/
# ├── .bashrc -> $PWD/files/.bashrc
# ├── .zprofile -> $PWD/files/.zprofile
# └── .zshrc -> $PWD/files/.zshrc
#
ln_dir_contents() {
    local src dest
    # Make sure src and dest are absolute dir paths
    src="$(cd "$1" && pwd)"
    dest="$(cd "$2" && pwd)"
    # Link files
    find "$src" -mindepth 1 -maxdepth 1 -exec ln -fst "$dest" '{}' \+
}

mkdir -p "$HOME/.config"

# Clone all submodules
git submodule update --init --recursive

# Link config files
ln_dir_contents files "$HOME"

# Link config directories
declare -a CONFIG_ITEMS
CONFIG_ITEMS=(nvim starship.toml)
case "$(uname -sr)" in
    Darwin\ *)
        CONFIG_ITEMS+=()
        ;;
    Linux\ *WSL*)
        CONFIG_ITEMS+=()
        ;;
    Linux\ *)
        CONFIG_ITEMS+=(compton.conf i3 zathura)
        ;;
    *)
        echo "Warning: Unsupported OS: $(uname -sr)" >&2
        ;;
esac
ln_dir_contents config "$HOME/.config"
unset CONFIG_ITEMS

# Install repository hooks
./install-hooks.sh
