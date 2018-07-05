# vim:syntax=zsh

local fg_color() { echo "%{$fg[$1]%}$2%{$reset_color%}"; }
local fg_bold() { echo "%{$fg_bold[$1]%}$2%{$reset_color%}"; }

_prompt_core() {
    local user="$(fg_bold green $USER)"
    local at="$(fg_color cyan @)"
    local host="$(fg_bold green $HOST)"
    local cwd="$(fg_bold cyan %~)"
    echo "${user}${at}${host} ${cwd}"
}

_color_bat_pct() { echo "%{$fg_bold[$1]%}$2%%$reset_color%}"; }
_prompt_status() {
    local status_items=()

    # Battery percent
    if which upower >/dev/null && bat &>/dev/null; then
        local state="$(bat | awk '/state/ {print $2}')"
        local percent="$(bat | awk '/percentage/ {print $2}' | tr -d '%')"

        local short_status
        if [[ $percent == 100 && $state != discharging ]]; then
            short_status="$(_color_bat_pct green $percent)"
            short_status+="$(fg_bold green ' UNPLUG')"
        elif (( percent > 25 )); then
            short_status="$(_color_bat_pct green $percent)"
        elif (( percent > 10 )); then
            short_status="$(_color_bat_pct yellow $percent)"
        elif [[ $percent -le 10 && $state == discharging ]]; then
            short_status="$(_color_bat_pct red $percent)"
            short_status+="$(fg_bold red ' PLUG IN')"
        else
            short_status="$(_color_bat_pct red $percent)"
        fi

        # Put ⚡ after battery percent if charging
        [[ $state == charging ]] && short_status+=⚡

        status_items+=( "$short_status" )
    fi

    # Is sudo password still saved
    sudo -n echo &>/dev/null &&
        status_items+=( "$(fg_bold red SUDO)" )

    # Background jobs
    local bg_jobs="$(jobs -l | wc -l)"
    (( bg_jobs > 0 )) &&
        status_items+=( "$(fg_color cyan "⚙:$bg_jobs")" )

    # Combine any activated status widgets
    if [[ $#status_items == 0 ]]; then
        echo ""
    else
        echo "[${(j:|:)status_items}]"  # Join status_items with |
    fi
}

_prompt_line_2() {
    # Green or red $ corresponding to $?
    echo "%(?:$(fg_bold green '$') :$(fg_bold red '$') )"
}

PROMPT='╭─ $(_prompt_core) $(_prompt_status)
╰─ $(_prompt_line_2)%{$reset_color%}'
