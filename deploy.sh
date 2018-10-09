#!/bin/bash

here="$(dirname "$0")"

no_ext() {
    sed -E 's/\.(c|cpp)$//' <<< "$1"
}


# Link config files
command ls -A "$here/files" | xargs -I % ln -fs "$HOME/.dot/files/%" "$HOME"

# Make directories for custom c libraries
rm -f "$HOME/.include"
ln -fs "$HOME/.dot/c-include" "$HOME/.include"
mkdir -p "$HOME/.lib"

# Create library
src_fns=( $(ls "$here/c-lib-src") )
for fn in "${src_fns[@]}"; do
    gcc -std=c11 -O3 -Wall -Werror -c "$here/c-lib-src/$fn"
    mv "./$(no_ext "$fn").o" "$HOME/.lib/"
done
ar qc "$HOME/.lib/libmylib.a" "$HOME/.lib/"*
ranlib "$HOME/.lib/libmylib.a"

# Install repository hooks
"$here/install-hooks.sh"
