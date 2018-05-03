#!/bin/bash

dir="$(dirname $0)/.git/hooks"

# rm ${dir}/*.sample


cat > "${dir}/commit-msg" <<EOF
#!/bin/bash

# Get number of characers in commit message
# -1 because of the added newline
len="\$(( \$(wc -m <\$1) - 1 ))"

if (( len > 50 )); then
    echo "Commit message is \$len characters" >&2
    echo "The maximum is 50" >&2
    exit 1
fi
EOF


cat > "${dir}/cpp-compile.sh" <<EOF
#!/bin/bash

dir="\$(dirname \$0)"

for file in "\$@"; do

    echo -e "\\nCompiling \$file ..."
    bin_name="\${file%.cpp}"
    # Compile cpp file into bin/
    g++ -std=c++11 "bin-src/\$file" -o "bin/\$bin_name"

    # Add bin/\$bin_name to .gitignore if it's not already there
    if ! grep "^bin/\$bin_name$" .gitignore >/dev/null; then
        echo "bin/\$bin_name" >> .gitignore
        "\${dir}/push-gitignore-changes.sh"
    fi

done
EOF


cat > "${dir}/post-merge" <<EOF
#!/bin/bash

# CWD is repo directory
dir="\$(dirname \$0)"  # dir=.git/hooks
options="-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src"


### Compile modified bin-src/ files ###

# to_compile = added and modified files
to_compile=( \$(git diff-tree \${options/_/AM} ORIG_HEAD HEAD) )

# to_compile += files not yet compiled
for file in \$(ls bin-src); do
    bin_name="\${file%.cpp}"
    if [[ ! -f "bin/\$bin_name" ]]; then
        to_compile+=( "\$file" )
    fi
done

# Remove duplicate items
while read -r uniq_file; do
    uniq_to_compile+=( "\$uniq_file" )
done < <(for file in "\${to_compile[@]}"; do echo "\$file"; done | sort -u)

"\${dir}/cpp-compile.sh" "\${uniq_to_compile[@]}"


### Update plugins if plugin changes were made in files/.vimrc ###

"\${dir}/update-vim-plugins.sh"
EOF


cat > "${dir}/pre-push" <<EOF
#!/bin/bash

url="\$2"
remote_commit=\$(git ls-remote "\$url" | grep HEAD | awk '{print \$1}')
current_commit=\$(git rev-parse HEAD)
options="-r --diff-filter=_ --no-commit-id --name-only --relative=bin-src"


### Compile added and modified files ###

# to_compile = added and modified files
to_compile=( \$(git diff-tree \${options/_/AM} \$remote_commit \$current_commit) )

# to_compile += files in bin-src but not in bin
for file in \$(ls bin-src); do
    bin_name="\${file%.cpp}"
    if [[ ! -f "bin/\$bin_name" ]]; then
        to_compile+=( "\$file" )
    fi
done

# Remove duplicate items
while read -r uniq_file; do
    uniq_to_compile+=( "\$uniq_file" )
done < <(for file in "\${to_compile[@]}"; do echo "\$file"; done | sort -u)

"\${dir}/cpp-compile.sh" "\${uniq_to_compile[@]}"


### Remove deleted files ###

# to_rm = removed files (includes old names of renamed files)
to_rm=( \$(git diff-tree \${options/_/D} \$remote_commit \$current_commit) )

for file in "\${to_rm[@]}"; do

    bin_name="\${file%.cpp}"
    echo "Removing bin/\$bin_name ..."
    rm -f "bin/\$bin_name"

    # Remove bin/\$bin_name from .gitignore
    sed -Ei "/^bin\/\${bin_name}\\n?/d" .gitignore
    if git ls-files -m | grep .gitignore >/dev/null; then
        "\${dir}/push-gitignore-changes.sh"
    fi

done
EOF


cat > "${dir}/push-gitignore-changes.sh" <<EOF
#!/bin/bash

err_echo() {
    echo "\$1" >&2
    exit 1
}

[[ \$(git diff --name-only .gitignore) == .gitignore ]] || exit 1

git add .gitignore >/dev/null || err_echo "Could not add .gitignore"

git commit -m "added bin/\$bin_name to .gitignore" >/dev/null ||
    err_echo "Could not commit .gitignore changes"

if [[ "\$(git rev-list --count origin...HEAD)" == 1 ]]; then
    echo "Pushing updated .gitignore ..."
    git push >/dev/null 2>&1 || err_echo "Could not push .gitignore changes"
fi
EOF


cat > "${dir}/update-vim-plugins.sh" <<EOF
#!/bin/bash

### Update plugins if plugin changes were made in files/.vimrc ###

dir="\$(dirname \$0)"

last_pull="\${dir}/last-pull"
current="\$(git rev-parse HEAD)"

if [[ -f "\$last_pull" ]]; then

    # Find changes to files/.vimrc that involve plugins
    git diff "\$(< \$last_pull)" "\$current" files/.vimrc |
        egrep "^(\+|-)" | egrep -v "^(\+|-){3}" |
        egrep "Plugin (\".+\"|'.+')"

    if [[ \$? == 0 ]]; then
        echo "Updating Vundle plugins ..."
        vim +PluginClean! +PluginInstall +qall
    fi

fi

echo "\$current" > "\$last_pull"
EOF


chmod +x "${dir}/"{commit-msg,cpp-compile.sh,post-merge,pre-push}
chmod +x "${dir}/"{push-gitignore-changes.sh,update-vim-plugins.sh}
