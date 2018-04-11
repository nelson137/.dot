ssh() {
    local src="$(dirname ${(%):-%x})"
    source "${src}/listbox.zsh"

    # Read connections.csv into arrays
    local names=()
    declare -A internals externals
    while IFS=, read -r name int ext; do
        names+=("$name")
        internals[$name]=$int
        externals[$name]=$ext
    done < "${src}/connections.csv"

    # Join options with |
    local options=$(local IFS="|"; echo "${names[*]}")
    # Run primary menu. return if error occurs
    listbox -t "Connect:" -o "$options" || return

    local int=${internals[$LISTBOX_CHOICE]}
    local ext=${externals[$LISTBOX_CHOICE]}

    if [[ -z $int ]]; then
        # There is only an external ip
        eval "command ssh $ext"
    elif [[ -z $ext ]]; then
        # There is only an internal ip
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
