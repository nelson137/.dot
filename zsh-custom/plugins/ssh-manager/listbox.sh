#!/bin/bash

lb_help() {
    echo "choose from list of options"
    echo "Usage: listbox [options]"
    echo "Example:"
    echo "  listbox -t title -o \"option 1|option 2|option 3\" -r resultVariable -a '>'"
    echo "Options:"
    echo "  -h, --help                         help"
    echo "  -t, --title                        list title"
    echo "  -o, --options \"option 1|option 2\"  listbox options"
    echo "  -r, --result <var>                 result variable"
    echo "  -a, --arrow <symbol>               selected option symbol"
}

move() {
    for it in "${opts[@]}"; do
        tput cuu1
    done
    tput el1
}

draw() {
    local idx=0 
    for it in "${opts[@]}"; do
        local str="";
        if [[ $idx == $choice ]]; then
            str+="$arrow "
        else
            str+="  "
        fi
        echo "$str$it"
        ((idx++))
    done
}

listbox() {
    while [[ $# > 0 ]]; do
        case $1 in
            -h|--help)
                lb_help
                return 0 ;;
            -o|--options)
                local OIFS=$IFS
                IFS=$'\n'
                opts=( $(echo "$2" | tr "|" "\n") )
                IFS=$OIFS
                shift ;;
            -t|--title)
                local title="$2"
                shift ;;
            -r|--result)
                local __result="$2"
                shift ;;
            -a|--arrow)
                local arrow="$2"
                shift ;;
            *)
        esac
        shift
    done

    local titleLen=${#title}
    if [[ -n "$title" ]]; then
        echo -e "\n  $title"
        printf "  "
        printf %"$titleLen"s | tr " " "-"
        echo ""
    fi

    [[ -z $arrow ]] && arrow=">"
    local len=${#opts[@]}
    local choice=0

    draw
    while true; do
        will_redraw=true
        key=$(bash -c 'read -n 1 -s key; echo $key')

        if [[ $key == q ]]; then
            break
        elif [[ $key == "" ]]; then
            choice=$((choice+1))

            if [[ -n $__result ]]; then
                eval "$__result=\"${opts[$choice]}\""
            else
                echo -e "\n${opts[$choice]}"
            fi
            break
        elif [[ $key == k ]]; then
            if [[ $choice > 0 ]]; then
                choice=$((choice-1))
            fi
        elif [[ $key == j ]]; then
            if [[ $choice < $((len-1)) ]]; then
                choice=$((choice+1))
            fi
        elif [[ $key == K ]]; then
            choice=0
        elif [[ $key == J ]]; then
            choice=$((len-1))
        else
            echo $key >> out.txt
            will_redraw=false
        fi

        if $will_redraw; then
            move; draw
        fi
    done
}
