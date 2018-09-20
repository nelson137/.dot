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
        grep -E '^(\+|-)' | grep -Ev '^(\+|-){3}' |
        grep -E "Plugin (\".+\"|'.+')"

    if [[ $? == 0 ]]; then
        echo 'Updating Vundle plugins ...'
        vim +PluginClean! +PluginInstall +qall
        echo
    fi
fi

echo "$current" > "$last_pull"
