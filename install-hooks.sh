#!/bin/bash

dir="$(dirname "$0")/.git/hooks"
mkdir -p "$dir"

rm -f ${dir}/*.sample


sed -r 's/^ {4}//' > "${dir}/cpp-compile.sh" <<'EOF'
    #!/bin/bash

    dir="$(dirname "$0")"  # dir=.git/hooks

    for file in "$@"; do
        echo -e "\nCompiling $file ..."
        bin_name="${file%.cpp}"
        # Compile cpp file into bin/
        g++ -std=c++11 "bin-src/$file" -o "bin/$bin_name"

        # Add bin/$bin_name to .gitignore if it's not already there
        if ! grep "^bin/$bin_name$" .gitignore >/dev/null; then
            echo "bin/$bin_name" >> .gitignore
            "${dir}/push-gitignore-changes.sh"
        fi
    done
EOF


sed -r 's/^ {4}//' > "${dir}/post-merge" <<'EOF'
    #!/bin/bash

    dir="$(dirname "$0")"  # dir=.git/hooks
    options="-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src"


    # Compile modified bin-src/ files

    # to_compile = added and modified files
    to_compile=( $(git diff-tree ${options/_/AM} ORIG_HEAD HEAD) )

    # to_compile += files not yet compiled
    for file in $(ls bin-src); do
        bin_name="${file%.cpp}"
        [[ ! -f "bin/$bin_name" ]] &&
            to_compile+=( "$file" )
    done

    # Remove duplicate items
    while read -r uniq_file; do
        uniq_to_compile+=( "$uniq_file" )
    done < <(for file in "${to_compile[@]}"; do echo "$file"; done | sort -u)

    # Compile modified cpp files
    "${dir}/cpp-compile.sh" "${uniq_to_compile[@]}"


    # Update plugins if changes were made in plugin section of files/.vimrc
    "${dir}/update-vim-plugins.sh"
EOF


sed -r 's/^ {4}//' > "${dir}/pre-push" <<'EOF'
    #!/bin/bash

    url="$2"
    dir="$(dirname "$0")"  # dir=.git/hooks
    # remote_commit = hash of last commit on remote
    remote_commit=$(git ls-remote "$url" | grep HEAD | awk '{print $1}')
    # current_commit = hash of last local commit
    current_commit=$(git rev-parse HEAD)
    options="-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src"


    ### Compile added and modified files ###

    # to_compile = added and modified files
    to_compile=( $(git diff-tree ${options/_/AM} $remote_commit $current_commit) )

    # to_compile += files in bin-src that aren't in bin
    for file in $(ls bin-src); do
        bin_name="${file%.cpp}"
        if [[ ! -f "bin/$bin_name" ]]; then
            to_compile+=( "$file" )
        fi
    done

    # Remove duplicate items
    while read -r uniq_file; do
        uniq_to_compile+=( "$uniq_file" )
    done < <(for file in "${to_compile[@]}"; do echo "$file"; done | sort -u)

    # Compile added, modified, and uncompiled cpp files
    "${dir}/cpp-compile.sh" "${uniq_to_compile[@]}"


    ### Remove deleted files ###

    # to_rm = removed files (includes old names of renamed files)
    to_rm=( $(git diff-tree ${options/_/D} $remote_commit $current_commit) )

    for file in "${to_rm[@]}"; do
        bin_name="${file%.cpp}"
        echo "Removing bin/$bin_name ..."
        rm -f "bin/$bin_name"

        # Remove bin/$bin_name from .gitignore
        sed -Ei "/^bin\/${bin_name}\n?/d" .gitignore
        # If .gitignore has been modified
        [[ $(git diff --name-only .gitignore) == .gitignore ]] &&
            "${dir}/push-gitignore-changes.sh"
    done


    # Update plugins if changes were made in plugin section of files/.vimrc
    "${dir}/update-vim-plugins.sh"
EOF


sed -r 's/^ {4}//' > "${dir}/push-gitignore-changes.sh" <<'EOF'
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


sed -r 's/^ {4}//' > "${dir}/update-vim-plugins.sh" <<'EOF'
    #!/bin/bash

    # Update plugins if plugin changes were made in files/.vimrc

    dir="$(dirname "$0")"  # dir=.git/hooks

    last_pull="${dir}/last-pull"
    current="$(git rev-parse HEAD)"  # current = hash of last local commit

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


chmod +x "${dir}/"{cpp-compile.sh,post-merge,pre-push}
chmod +x "${dir}/"{push-gitignore-changes.sh,update-vim-plugins.sh}
