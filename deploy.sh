#!/bin/bash

here="$(cd "$(dirname "$0")" && pwd)"

no_ext() {
    sed -E 's/\.(c|cpp)$//' <<< "$1"
}


# Link config files
command ls -A "$here/files" | xargs -I % ln -fs "$HOME/.dot/files/%" "$HOME"

# Make directories for libraries
rm -rf "$HOME"/.{include,lib}
mkdir -p "$HOME"/.include "$HOME"/.lib/{c,cpp}
ln -fs "$here/lib/c/include" "$HOME/.include/c"
ln -fs "$here/lib/cpp/include" "$HOME/.include/cpp"

# Create C and C++ libraries
for lang in c cpp; do
    lib_names=( $(ls "$here/lib/$lang/src") )
    for lib in "${lib_names[@]}"; do
        mkdir -p "$HOME/.lib/$lang/$lib"
        src_fns=( $(ls "$here/lib/$lang/src/$lib") )
        for src_fn in "${src_fns[@]}"; do
            obj_fn="$(no_ext "$src_fn").o"
            if [[ "$lang" == 'c' ]]; then
                gcc -std=c11 -O3 -Wall -Werror -c \
                    -I"$HOME/.include/c" \
                    "$here/lib/c/src/$lib/$src_fn" \
                    -o "$HOME/.lib/c/$lib/$obj_fn"
            else
                g++ -std=c++11 -O3 -Wall -Werror -c \
                    -I"$HOME/.include/cpp" \
                    "$here/lib/cpp/src/$lib/$src_fn" \
                    -o "$HOME/.lib/cpp/$lib/$obj_fn"
            fi
            ar rc "$HOME/.lib/$lang/lib$lib.a" "$HOME/.lib/$lang/$lib/$obj_fn"
        done
        ranlib "$HOME/.lib/$lang/lib$lib.a"
    done
done

# Install repository hooks
"$here/install-hooks.sh"
