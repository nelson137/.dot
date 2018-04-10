listbox_help() {
    echo "Usage: listbox [options]"
    echo "Example:"
    echo "  listbox -t title -o \"option 1|option 2|option 3\""
    echo "Options:"
    echo "  -h, --help                  help"
    echo "  -t, --title                 list title"
    echo "  -o, --options \"op 1|op 2\"   listbox options"
    echo "  -a, --arrow <symbol>        selected option symbol"
}

listbox() {
    unset title opts arrow no_echo

    while [[ $# > 0 ]]; do
        case $1 in
            -h|--help)
                listbox_help
                return 0 ;;
            -t|--title)
                local title="$2"
                shift ;;
            -o|--options)
                local OIFS=$IFS
                IFS=$'\n'
                opts=( $(echo "$2" | tr "|" "\n") )
                IFS=$OIFS
                shift ;;
            -a|--arrow)
                local arrow="$2"
                shift ;;
            -n|--no-echo)
                local no_echo=true ;;
            *)
        esac
        shift
    done

    if [[ -z $opts ]]; then
        echo "Error: Options required"
        return 1
    fi

    move() {
        for opt in "${opts[@]}"; do
            tput cuu1
        done
        tput el1
    }

    draw() {
        local idx=1
        for opt in "${opts[@]}"; do
            local prefix=""
            if [[ $idx == $choice ]]; then
                prefix+="$arrow"
            else
                prefix+=$(printf %${#arrow}s)
            fi
            echo "$prefix $opt"
            ((idx++))
        done
    }

    if [[ -n $title ]]; then
        local Lspace=" $(printf %${#arrow}s)"
        printf "\n$Lspace$title\n$Lspace"
        printf %"${#title}"s | tr " " "-"
        echo ""
    fi

    [[ -z $arrow ]] && arrow=">"
    local len=${#opts[@]}
    local choice=1
    local will_redraw=true
    draw

    while true; do
        key=$(bash -c 'read -n 1 -s key; echo $key')

        if [[ $key == q ]]; then
            echo ""
            return 1
        elif [[ $key == "" ]]; then
            if $no_echo; then
                eval "export LISTBOX_CHOICE=\"${opts[$choice]}\""
                echo ""
            else
                echo -e "\n${opts[$choice]}"
            fi
            break
        elif [[ $key == k || $key == A ]]; then
            if [[ $choice > 1 ]]; then
                ((choice--))
            else
                will_redraw=false
            fi
        elif [[ $key == j || $key == B ]]; then
            if [[ $choice < $len ]]; then
                ((choice++))
            else
                will_redraw=false
            fi
        elif [[ $key == K ]]; then
            choice=1
        elif [[ $key == J ]]; then
            choice=$len
        else
            will_redraw=false
        fi

        if $will_redraw; then
            move
            draw
        else
            will_redraw=true
        fi
    done

    unset title opts arrow no_echo
}
