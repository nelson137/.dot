# vim:syntax=zsh


ret_status="%(?.%{$fg_bold[green]%}.%{$fg_bold[red]%})\$%{$reset_color%}"


style() {
    print -P "%F{$1}$2%f"
}


prompt_core() {
    local user="$(style 046 $USER)"
    local   at="$(style 050 @    )"
    local host="$(style 046 $HOST)"
    local  cwd="$(style 050 %~   )"
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
