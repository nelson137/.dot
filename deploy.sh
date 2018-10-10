#!/bin/bash

here="$(dirname "$0")"

no_ext() {
    sed -E 's/\.(c|cpp)$//' <<< "$1"
}


# Link config files
command ls -A "$here/files" | xargs -I % ln -fs "$HOME/.dot/files/%" "$HOME"

# Make directories for C  libraries
rm -f "$HOME/.include"
ln -fs "$HOME/.dot/c-include" "$HOME/.include"
mkdir -p "$HOME/.lib"

# Create C libraries
lib_names=( $(ls "$here/c-lib-src") )
for lib_name in "${lib_names[@]}"; do
    mkdir -p "$HOME/.lib/$lib_name"
    src_fns=( $(ls "$here/c-lib-src/$lib_name") )
    for src_fn in "${src_fns[@]}"; do
        obj_fn="$(no_ext "$src_fn").o"
        gcc -std=c11 -O3 -Wall -Werror -c "$here/c-lib-src/$lib_name/$src_fn" \
            -o "$HOME/.lib/$lib_name/$obj_fn"
        ar rc "$HOME/.lib/lib$lib_name.a" "$HOME/.lib/$lib_name/$obj_fn"
    done
    ranlib "$HOME/.lib/lib$lib_name.a"
done

# Install repository hooks
"$here/install-hooks.sh"
