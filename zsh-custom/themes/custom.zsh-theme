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

_prompt_status() {
    local color_bat_pct() { echo "%{$fg_bold[$1]%}$2%%$reset_color%}"; }
    local status_items=()

    # Battery percent
    if which upower >/dev/null && bat >/dev/null 2>&1; then
        local bat_status="$(bat | awk '/state/ {print $2}')"
        local bat_percent="$(bat | awk '/percentage/ {print $2}' | tr -d '%')"
        if [[ $bat_percent == 100 && $bat_status != discharging ]]; then
            local pct="$(color_bat_pct green $bat_percent)"
            status_items+=( "${pct}$(fg_bold green ' UNPLUG')" )
        elif (( $bat_percent > 25 )); then
            status_items+=( "$(color_bat_pct green $bat_percent)" )
        elif (( $bat_percent > 10 )); then
            status_items+=( "$(color_bat_pct yellow $bat_percent)" )
        elif [[ $bat_percent -le 10 && $bat_status == discharging ]]; then
            local pct="$(color_bat_pct red $bat_percent)"
            status_items+=( "${pct}$(fg_bold red ' PLUG IN')" )
        else
            status_items+=( "$(color_bat_pct red $bat_percent)" )
        fi
    fi

    # Background jobs
    local bg_jobs="$(jobs -l | wc -l)"
    (( $bg_jobs > 0 )) &&
        status_items+=( "$(fg_color cyan "\u2699:$bg_jobs")" )

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
