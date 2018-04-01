ssh() {
    local src="$(dirname ${(%):-%x})"
    source "${src}/listbox.zsh"

    local names=()
    local internals=()
    local externals=()
    while IFS=, read -r name int ext; do
        names+=("$name")
        internals+=("$int")
        externals+=("$ext")
    done < "${src}/connections.csv"

    local options=$(local IFS="|"; echo "${names[*]}")
    listbox -t "Connect:" -o "$options" -r || return

    local index
    for ((i=1; i<=${#names}; i++)); do
        if [[ ${names[i]} == $LISTBOX_CHOICE ]]; then
            index=$i
            break
        fi
    done

    local int="${internals[index]}"
    local ext="${externals[index]}"
    if [[ -z ${internals[index]} ]]; then
        eval "command ssh $ext"
    elif [[ -z ${externals[index]} ]]; then
        eval "command ssh $int"
    else
        local title="Host Location:"
        local options="Internal|External"
        listbox -t "$title" -o "$options" -r || return
        if [[ $LISTBOX_CHOICE == Internal ]]; then
            eval "command ssh $int"
        else
            eval "command ssh $ext"
        fi
    fi
}
