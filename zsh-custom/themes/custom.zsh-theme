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

    # Background jobs
    local bg_jobs="$(jobs -l | wc -l)"
    (( bg_jobs > 0 )) &&
        status_items+=( "$(style 0 cyan "⚙:$bg_jobs")" )

    # Display status items with space as separator
    echo "${(j: :)status_items}"
}


PROMPT='╓ $(prompt_core) $(prompt_status)
╙ $ret_status '
