#!/bin/bash

set -e

ln_dir_contents() {
    # Make sure src and dest are absolute dir paths
    local src="$(cd "$1" && pwd)"
    local dest="$(cd "$2" && pwd)"
    # Link files
    find "$src" -mindepth 1 -maxdepth 1 -exec ln -fst "$dest" '{}' \+
}

pushd "$(dirname "${BASH_SOURCE[0]}")"

    # Clone all submodules
    git submodule update --init --recursive

    # Link config files
    ln_dir_contents files "$HOME"

    # Link config directories
    ln_dir_contents .config "$HOME/.config"

    # Install repository hooks
    ./install-hooks.sh

    # Install fzf
    ./components/fzf/install --bin --64

popd
