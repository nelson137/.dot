#!/bin/zsh



lb_move() {
    for opt in "${opts[@]}"; do
        tput cuu1
    done
    tput el1
}



lb_draw() {
    local idx=1
    local prefix
    for opt in "${opts[@]}"; do
        prefix=''
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
    local title OIFS arrow
    while (( $# > 0 )); do
        case "$1" in
            -t|--title)
                title="$2"
                shift ;;
            -o|--options)
                OIFS="$IFS"
                IFS=$'\n'
                opts=( $(tr '|' '\n' <<< "$2") )
                IFS="$OIFS"
                shift ;;
            -a|--arrow)
                arrow="$2"
                shift ;;
            *)
        esac
        shift
    done

    [[ ! $arrow ]] && arrow='>'

    if [[ $title ]]; then
        local Lspace=" $(printf %${#arrow}s)"
        printf "\n${Lspace}${title}\n${Lspace}"
        printf "%${#title}s" | tr ' ' '-'
        echo
    fi

    local len="${#opts[@]}"
    local choice=1
    local will_redraw

    lb_draw

    while true; do
        key="$(bash -c 'read -sn 1 key; echo "$key"')"
        will_redraw=1

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
                    will_redraw=0
                fi ;;
            j|B)
                if (( $choice < $len )); then
                    ((choice++))
                else
                    will_redraw=0
                fi ;;
            K)
                choice=1 ;;
            J)
                choice="$len" ;;
            *)
                will_redraw=0 ;;
        esac

        if [[ "$will_redraw" ]]; then
            lb_move
            lb_draw
        fi
    done

    unset opts
}
