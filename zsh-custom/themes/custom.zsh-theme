# vim:syntax=zsh

_prompt_core() {
    local user="%{$fg_bold[green]%}$USER"
    local at="%{$fg[cyan]%}@"
    local host="%{$fg_bold[green]%}$HOST"
    local cwd="%{$fg[cyan]%}%~%{$reset_color%}"
    echo "${user}${at}${host} ${cwd}"
}

_prompt_status() {
    local status_items=()

    # Battery percent
    if which bat >/dev/null; then
        local bat_percent="$(bat | tail -1 | awk '{print $2}')"
        if [[ ${bat_percent%\%} -gt 25 ]]; then
            bat_percent="%{$fg_bold[green]%}$bat_percent"
        elif [[ ${bat_percent%\%} -gt 10 ]]; then
            bat_percent="%{$fg_bold[yellow]%}$bat_percent"
        else
            bat_percent="%{$fg_bold[red]%}$bat_percent"
        fi
        status_items+=( "${bat_percent}%$reset_color%}" )
    fi

    echo "${(j:|:)status_items}"  # Join status_items with |
}

_prompt_line_2() {
    # Green or red $
    local ret_status="%(?:%{$fg_bold[green]%}\$ :%{$fg_bold[red]%}\$ )"
    echo "${ret_status}"
}

PROMPT='╭─ $(_prompt_core) [$(_prompt_status)]
╰─ $(_prompt_line_2)%{$reset_color%}'
