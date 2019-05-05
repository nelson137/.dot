#!/bin/bash

here="$(cd "$(dirname "$0")" && pwd)"

listdir() {
    find "$1" -maxdepth 1 | sed 1d
}

no_ext() {
    sed -E 's/\.(c|cpp)$//' <<< "$1"
}

lang() {
    grep -q '\.c$' <<< "$1" && echo c || echo cpp
}


# Link config files
listdir "$here/files" | xargs -I % ln -fs % "$HOME"

# Make directories for libraries
rm -rf "$HOME"/.{include,lib}
mkdir "$HOME"/.{include,lib}

# Create C and C++ libraries
for lib in $(ls "$here/lib"); do
    ln -fs "$here/lib/$lang/$lib/include/"* "$HOME/.include/$lang/"
    mkdir -p "$HOME/.lib/$lang/$lib"
    for src_fn in $(ls "$here/lib/$lang/$lib/src"); do
        obj_fn="$(no_ext "$src_fn").o"
        if [[ "$(lang "$src_fn")" == 'c' ]]; then
            gcc -std=c11 -O3 -Wall -Werror -c \
                "$here/lib/$lib/src/$src_fn" \
                -o "$HOME/.lib/$lib/$obj_fn" \
                -I"$HOME/.include"
        else
            g++ -std=c++17 -O3 -Wall -Werror -c \
                "$here/lib/$lib/src/$src_fn" \
                -o "$HOME/.lib/$lib/$obj_fn" \
                -I"$HOME/.include"
        fi
        ar rc "$HOME/.lib/lib$lib.a" "$HOME/.lib/$lib/$obj_fn"
    done
    ranlib "$HOME/.lib/lib$lib.a"
done

# Install repository hooks
"$here/install-hooks.sh"
