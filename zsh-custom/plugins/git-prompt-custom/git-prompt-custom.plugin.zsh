# Modifies git_super_status function to include a waring if the
# current git directory is behind or has diverged from origin/master.

_git_pd_status() {
    local git_dir="$(git rev-parse --git-dir)"
    local pd_status_file="${git_dir}/pd_status"
    local local_="$(git rev-parse HEAD)"
    local remote="$(git ls-remote origin 2>/dev/null | awk '/HEAD/ {print $1}')"
    local base="$(git merge-base HEAD origin 2>/dev/null)"

    local pd_status
    if [[ -z $remote ]]; then
        # Cannot access remote
        pd_status="%{$fg[yellow]%}!%{$reset_color%}"
    else
        if [[ $local_ == $remote ]]; then
            true  # Up-to-date
        elif [[ $local_ == $base ]]; then
            pd_status="PULL"
        elif [[ $remote == $base ]]; then
            true  # Need to push
        else
            pd_status="DIVERGED"
        fi
    fi

    echo "$pd_status" > "$pd_status_file"
}


# which git_super_status >/dev/null 2>&1 || return
gss="$(typeset -f | awk '/git_super_status/,/^}/')"

# Line number of 'STATUS="$ZSH' in git_super_status()
n="$(
    echo "$gss" |
    grep -n 'STATUS="\$ZSH' |
    awk '{print $1}' |
    cut -d ':' -f 1
)"

# Put each line of git_super_status() into lines
typeset -a lines
while read -r line; do
    lines+=( "$line" )
done <<< "$gss"

typeset -a pull_diverge_status
pull_diverge_status=(
    'local now="$(date +%s)"'
    'local git_dir="$(git rev-parse --git-dir)"'
    'local last_run_file="${git_dir}/pd_status.last-run"'
    '[[ ! -f "$last_run_file" ]] && echo "$now" > "$last_run_file"'
    'local last_run="$(< "$last_run_file")"'
    'local pd_status_file="${git_dir}/pd_status"'
    'touch "$pd_status_file"'
    'if (( now - last_run > 30 )); then'
    '    _git_pd_status >/dev/null &'
    '    echo "$now" > "$last_run_file"'
    'fi'
    'pd_status="$(< "$pd_status_file")"'
    'local prefix="%{$fg_bold[red]%}"'
    'local suffix="%{$reset_color%}|"'
    'ZSH_THEME_GIT_PD_STATUS=""'
    '[[ -n $pd_status ]] &&'
    '    ZSH_THEME_GIT_PD_STATUS="${prefix}${pd_status}${suffix}"'
)

new_line_n='STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX'
new_line_n+='$ZSH_THEME_GIT_PD_STATUS$ZSH_THEME_GIT_PROMPT_BRANCH'
new_line_n+='$GIT_BRANCH%{${reset_color}%}"'

lines=(
    $lines[1,$((n-1))]        # Code before line n
    $pull_diverge_status      # Pull/diverge status
    $new_line_n               # Modified line n
    $lines[$((n+1)),$#lines]  # Code after line n
)

# Define the modified function
eval "${(j:;:)lines}"  # Join lines with ;
