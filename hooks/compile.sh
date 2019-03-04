#!/bin/bash

# Exit if bin-src/ does not exist
[[ -d bin-src ]] || exit 0


no_ext() {
    sed -E 's/\.(c|cpp)$//'
}


get_ext() {
    sed -E 's/^.+\.([^. ]+)$/\1/' <<< "$1"
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
    exe="$(basename "$fn" | no_ext)"
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


# Put newline between git output and compile messages
[[ "$context" == post-merge ]] && (( "${#to_compile[@]}" > 0 )) &&
    echo


# Compile source code files into bin/compiled/
for fn in "${to_compile[@]}"; do
    echo "Compiling bin-src/$fn ..."
    ext="$(get_ext "$fn")"
    exe="$(no_ext <<< "$fn")"
    if [[ "$ext" == c ]]; then
        to cf -o "bin/compiled/$exe" "bin-src/$fn"
    elif [[ "$ext" == cpp ]]; then
        to cf -o "bin/compiled/$exe" "bin-src/$fn"
    else
        printf "\r\033[A"
        echo "compile.sh: filetype not recognized: $fn" >&2
    fi
done


# Put newline between compile messages and remove messages/git output
[[ "$context" == pre-push ]] && (( "${#to_compile[@]}" > 0 )) &&
    echo


typeset -a to_rm
if [[ "$context" == pre-push ]]; then
    # Removed files (includes old names of renamed files)
    to_rm=(
        $(git diff-tree ${options/_/D} "$remote_commit" "$current_commit" |
            no_ext)
    )
elif [[ "$context" == post-merge ]]; then
    # Files in bin-src/ without their extensions
    src=( $(ls -1 bin-src | no_ext) )
    # Files in bin/compiled/
    exe=( $(ls bin/compiled) )
    # Files in both bin-src/ and bin/compiled/
    intersecion=( $(printf '%s\n' "${src[@]}" "${exe[@]}" | sort | uniq -D) )
    # Files in bin/compiled/ that aren't in bin-src/
    # set(exe) - set(src)
    to_rm=( $(printf '%s\n' "${intersecion[@]}" "${exe[@]}" | sort | uniq -u) )
fi

# Put newline between git output/compile messages and remove messages
[[ "$context" == post-merge ]] && (( "${#to_rm[@]}" > 0 )) &&
    echo

# Remove binary for each removed source code file
for fn in "${to_rm[@]}"; do
    echo "Removing bin/compiled/$fn ..."
    rm -f "bin/compiled/$fn"
done


# Put newline between removed binary's message and git output
[[ "$context" == pre-push ]] && (( "${#to_rm[@]}" > 0 )) &&
    echo
