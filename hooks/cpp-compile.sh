#!/bin/bash


no_ext() {
    command sed -r 's/\.(c|cpp)$//' <<< "$1"
}


get_ext() {
    command sed -r 's/^.+\.([^. ]+)$/\1/' <<< "$1"
}


# Make sure directory for compiled bin files exists
mkdir -p bin/compiled

# <git dir>/hooks
hooks="$(dirname "$0")"

# Which hook this script is being executed by
context="$1"

# Hash of last commit on remote
remote_commit="$2"

# Hash of last local commit
current_commit="$3"

# git diff-tree options
options='-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src'


# Added and modified files
[[ "$context" == post-merge ]] &&
    trees='ORIG_HEAD HEAD'
[[ "$context" == pre-push ]] &&
    trees="$remote_commit $current_commit"
typeset -a added_modified
while read -r fn; do
    added_modified+=( "$(basename "$fn")" )
done < <(git diff-tree ${options/_/AM} $trees)

# Soure code files not compiled
typeset -a not_compiled
while read -r fn; do
    exe="$(no_ext "$(basename "$fn")")"
    [[ ! -f "bin/compiled/$exe" ]] &&
        not_compiled+=( "$(basename "$fn")" )
done < <(find bin-src -type f)

# Remove duplicate file names
typeset -a to_compile
while read -r uniq_fn; do
    to_compile+=( "$uniq_fn" )
done < <(
    { for f in "${added_modified[@]}"; do echo "$f"; done
      for f in "${not_compiled[@]}"; do echo "$f"; done
    } | sort -u
)


# Compile source code files into bin/compiled/
for fn in "${to_compile[@]}"; do
    echo "Compiling $fn ..."
    ext="$(get_ext "$fn")"
    exe="$(no_ext "$fn")"
    if [[ "$ext" == c ]]; then
        gcc -std=c11 -O3 -Wall -Werror "bin-src/$fn" -o "bin/compiled/$exe"
    elif [[ "$ext" == cpp ]]; then
        g++ -std=c++11 "bin-src/$fn" -o "bin/compiled/$exe"
    else
        printf "\r\033[A"
        echo "cpp-compile.sh: filetype not recognized: $fn" >&2
    fi
done


# Put newline between compile messages and git output
(( "${#to_compile[@]}" > 0 )) &&
    echo

# Delete binaries of removed cpp files
if [[ "$context" == pre-push ]]; then
    # Removed files (includes old names of renamed files)
    to_rm=(
        $(git diff-tree ${options/_/D} "$remote_commit" "$current_commit")
    )

    # Remove binaries from bin/compiled/
    for fn in "${to_rm[@]}"; do
        exe="$(no_ext "$fn")"
        if [[ -f "bin/compiled/$exe" ]]; then
            echo "Removing bin/compiled/$exe ..."
            rm -f "bin/compiled/$exe"
        fi
    done
fi

# Put newline between removed binaries message and git output
(( "${#to_rm[@]}" > 0 )) &&
    echo
