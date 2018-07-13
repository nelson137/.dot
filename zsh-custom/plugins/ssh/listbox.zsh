#!/bin/zsh

lb_move() {
    for opt in "${opts[@]}"; do
        tput cuu1
    done
    tput el1
}

lb_draw() {
    local idx=1
    for opt in "${opts[@]}"; do
        local prefix=''
        if [[ $idx == $choice ]]; then
            prefix+="$arrow"
        else
            prefix+="$(printf %${#arrow}s)"
        fi
        echo "$prefix $opt"
        ((idx++))
    done
}

listbox() {
    unset title opts arrow

    local no_echo=false
    while (( $# > 0 )); do
        case "$1" in
            -t|--title)
                local title="$2"
                shift ;;
            -o|--options)
                local OIFS="$IFS"
                IFS=$'\n'
                opts=( $(echo "$2" | tr '|' '\n') )
                IFS="$OIFS"
                shift ;;
            -a|--arrow)
                local arrow="$2"
                shift ;;
            *)
        esac
        shift
    done

    if [[ -n $title ]]; then
        local Lspace=" $(printf %${#arrow}s)"
        printf "\n$Lspace$title\n$Lspace"
        printf %"${#title}"s | tr ' ' '-'
        echo
    fi

    [[ -z $arrow ]] && arrow='>'
    local len="${#opts[@]}"
    local choice=1
    local will_redraw=true
    lb_draw

    while true; do
        key="$(bash -c 'read -n 1 -s key; echo $key')"

        case "$key" in
            q)
                echo
                return 1 ;;
            '')
                echo
                export LISTBOX_CHOICE="${opts[choice]}"
                break ;;
            k|A)
                if (( $choice > 1 )); then
                    ((choice--))
                else
                    will_redraw=false
                fi ;;
            j|B)
                if (( $choice < $len )); then
                    ((choice++))
                else
                    will_redraw=false
                fi ;;
            K)
                choice=1 ;;
            J)
                choice="$len" ;;
            *)
                will_redraw=false ;;
        esac

        if "$will_redraw"; then
            lb_move
            lb_draw
        else
            will_redraw=true
        fi
    done

    unset opts
}
