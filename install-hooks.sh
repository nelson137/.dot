#!/bin/bash

hooks="$(dirname "$0")/.git/hooks"
mkdir -p "$hooks"

rm -f ${hooks}/*.sample


sed -r 's/^ {4}//' > "${hooks}/cpp-compile.sh" <<'EOF'
    #!/bin/bash

    # <git dir>/hooks
    hooks="$(dirname "$0")"

    # Which hook this script is being executed by
    context="$1"

    # Hash of last commit on remote
    remote_commit="$2"

    # Hash of last local commit
    current_commit="$3"

    # git diff-tree options
    options="-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src"


    # Added and modified files
    [[ "$context" == post-merge ]] &&
        trees='ORIG_HEAD HEAD'
    [[ "$context" == pre-push ]] &&
        trees="$remote_commit $current_commit"
    to_compile=( $(git diff-tree ${options/_/AM} $trees) )

    # Files not yet compiled
    while read -r file; do
        bin_name="$(basename "${file%.cpp}")"
        [[ ! -f "bin/$bin_name" ]] &&
            to_compile+=( "$file" )
    done < <(find bin-src -type f -name '*.cpp')

    # Remove duplicate items
    uniq_to_compile=()
    while read -r uniq_file; do
        uniq_to_compile+=( "$uniq_file" )
    done < <(for file in "${to_compile[@]}"; do echo "$file"; done | sort -u)

    for file in "${uniq_to_compile[@]}"; do
        # Compile cpp file into bin/
        echo "Compiling $file ..."
        bin_name="${file%.cpp}"
        g++ -std=c++11 "bin-src/$file" -o "bin/$bin_name"

        # Add bin/$bin_name to .gitignore if it's not already there
        if ! grep "^bin/$bin_name$" .gitignore >/dev/null; then
            echo "bin/$bin_name" >> .gitignore
            "${hooks}/push-gitignore-changes.sh"
        fi
    done
    echo

    if [[ "$context" == pre-push ]]; then
        # Remove binaries of deleted cpp files

        # Removed files (includes old names of renamed files)
        to_rm=(
            $(git diff-tree ${options/_/D} "$remote_commit" "$current_commit")
        )

        for file in "${to_rm[@]}"; do
            # Remove binary from bin/
            bin_name="${file%.cpp}"
            echo "Removing bin/$bin_name ..."
            rm -f "bin/$bin_name"

            # Remove bin/$bin_name from .gitignore
            sed -Ei "/^bin\/${bin_name}\n?/d" .gitignore
            # If .gitignore has been modified
            [[ $(git diff --name-only .gitignore) == .gitignore ]] &&
                "${hooks}/push-gitignore-changes.sh"
        done
    fi
EOF


sed -r 's/^ {4}//' > "${hooks}/post-merge" <<'EOF'
    #!/bin/bash

    # <git dir>/hooks
    hooks="$(dirname "$0")"


    # Compile added, modified, and uncompiled bin-src/ files
    "${hooks}/cpp-compile.sh" post-merge

    # Update plugins if changes were made in plugin section of files/.vimrc
    "${hooks}/update-vim-plugins.sh"
EOF


sed -r 's/^ {4}//' > "${hooks}/pre-push" <<'EOF'
    #!/bin/bash

    # <git dir>/hooks
    hooks="$(dirname "$0")"

    # Url of reciever of the push
    url="$2"

    # Hash of last commit on remote
    remote_commit=$(git ls-remote "$url" | grep HEAD | awk '{print $1}')

    # Hash of last local commit
    current_commit=$(git rev-parse HEAD)


    # Compile added, modified, and uncompiled bin-src/ files
    "${hooks}/cpp-compile.sh" pre-push "$remote_commit" "$current_commit"


    # Update plugins if changes were made in plugin section of files/.vimrc
    "${hooks}/update-vim-plugins.sh"
EOF


sed -r 's/^ {4}//' > "${hooks}/push-gitignore-changes.sh" <<'EOF'
    #!/bin/bash

    err_echo() {
        echo "$1" >&2
        exit 1
    }

    # Exit if .gitignore has not been modified
    [[ $(git diff --name-only .gitignore) == .gitignore ]] || exit 1

    git add .gitignore >/dev/null

    git commit -m "added bin/$bin_name to .gitignore" >/dev/null ||
        err_echo "Could not commit .gitignore changes"

    # If ahead by 1 commit
    if [[ "$(git rev-list --count origin...HEAD)" == 1 ]]; then
        echo "Pushing updated .gitignore ..."
        git push &>/dev/null || err_echo "Could not push .gitignore changes"
    fi
EOF


sed -r 's/^ {4}//' > "${hooks}/update-vim-plugins.sh" <<'EOF'
    #!/bin/bash

    # Update plugins if plugin changes were made in files/.vimrc

    # <git dir>/hooks
    hooks="$(dirname "$0")"

    # Time of last pull
    last_pull="${hooks}/last-pull"

    # Hash of last local commit
    current="$(git rev-parse HEAD)"


    if [[ -f "$last_pull" ]]; then
        # Find changes to files/.vimrc that involve plugins
        git diff "$(< $last_pull)" "$current" files/.vimrc |
            egrep "^(\+|-)" | egrep -v "^(\+|-){3}" |
            egrep "Plugin (\".+\"|'.+')"

        if [[ $? == 0 ]]; then
            echo "Updating Vundle plugins ..."
            vim +PluginClean! +PluginInstall +qall
        fi
    fi

    echo "$current" > "$last_pull"
EOF


chmod +x "${hooks}/"{cpp-compile.sh,post-merge,pre-push}
chmod +x "${hooks}/"{push-gitignore-changes.sh,update-vim-plugins.sh}
