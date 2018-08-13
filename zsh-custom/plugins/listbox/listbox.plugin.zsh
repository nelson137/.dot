#!/bin/zsh

nl='
'



lb_move() {
    for n in {1..$1}; do
        tput cuu1
    done
    tput el1
}



lb_draw() {
    local choice="$1"; shift
    local arrow="$1"; shift
    for (( i=1; i<=$#; i++ )); do
        prefix=''
        if [[ $i == $choice ]]; then
            prefix+="$arrow"
        else
            prefix+="$(printf "%${#arrow}s")"
        fi
        eval "echo \$prefix \$opts[$i]"
    done
}



listbox() {
    local title OIFS arrow
    local -a opts
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
    local key will_redraw choice=1

    lb_draw "$choice" "$arrow" "$opts[@]"

    while true; do
        read -sk key
        will_redraw=1

        case "$key" in
            q)
                echo
                return 1 ;;
            $nl)
                echo
                export LISTBOX_CHOICE="$opts[choice]"
                break ;;
            k|A)
                if (( choice > 1 )); then
                    ((choice--))
                else
                    will_redraw=0
                fi ;;
            j|B)
                if (( choice < len )); then
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
            lb_move "$len"
            lb_draw "$choice" "$arrow" "$opts[@]"
        fi
    done
}
