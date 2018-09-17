#!/bin/sh


here="$(dirname "$0")"

# Link config files
command ls -A "$here/files" | xargs -I % ln -fs "$HOME/.dot/files/%" "$HOME"

# Install repository hooks
"$here/install-hooks.sh"
