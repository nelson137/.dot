# vim:syntax=zsh


ret_status="%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})\$%{$reset_color%}"


style() {
    # $1: 1 for bold, 0 for not bold
    # $2: fg color
    # $3: text to style
    if [[ $1 == 1 ]]; then
        print -P "%F{$2}%B$3%b%f"
    else
        print -P "%F{$2}$3%f"
    fi
}


prompt_core() {
    local user="$(style 1 green $USER)"
    local at="$(style 0 cyan @)"
    local host="$(style 1 green $HOST)"
    local cwd="$(style 1 cyan %~)"
    print -P "${user}${at}${host} ${cwd}"
}


prompt_status() {
    local status_items=()

    # Battery percent
    if which upower &>/dev/null && bat &>/dev/null; then
        local state="$(bat | awk '/state/ {print $2}')"
        local percent="$(bat | awk '/percentage/ {print $2}' | tr -d '%')"

        local short_status
        if [[ $percent == 100 && $state != discharging ]]; then
            short_status="$(style 1 green "$percent%%%%")"
            short_status+="$(style 1 green ' UNPLUG')"
        elif (( percent > 25 )); then
            short_status="$(style 1 green "$percent%%%%")"
        elif (( percent > 10 )); then
            short_status="$(style 1 yellow "$percent%%%%")"
        elif [[ $percent -le 10 && $state == discharging ]]; then
            short_status="$(style 1 red "$percent%%%%")"
            short_status+="$(style 1 red ' PLUG IN')"
        else
            short_status="$(style 1 red "$percent%%%%")"
        fi

        # Put ⚡ after battery percent if charging
        [[ $state == charging ]] && short_status+=⚡

        status_items+=( "$short_status" )
    fi

    # Is sudo password still saved
    sudo -n echo &>/dev/null &&
        status_items+=( "$(style 1 red SUDO)" )

    # Background jobs
    local bg_jobs="$(jobs -l | wc -l)"
    (( bg_jobs > 0 )) &&
        status_items+=( "$(style 0 cyan "⚙:$bg_jobs")" )

    # Combine any activated status widgets
    if [[ $#status_items == 0 ]]; then
        echo ""
    else
        echo "[${(j:|:)status_items}]"  # Join status_items with |
    fi
}


PROMPT='╓ $(prompt_core) $(prompt_status)
╙ $ret_status '
