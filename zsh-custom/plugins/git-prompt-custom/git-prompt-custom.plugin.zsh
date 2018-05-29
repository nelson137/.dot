# vim:syntax=zsh

pull_diverge_status=(
    'local local_="$(git rev-parse @)"'
    'local url="$(git remote get-url origin)"'
    "local remote=\"\$(git ls-remote \"\$url\" | awk '/HEAD/ {print \$1}')\""
    'local base="$(git merge-base @ @{u})"'
    'local custom_status'
    'if [[ $local_ == $remote ]]; then'
    '    true'
    'elif [[ $local_ == $base ]]; then'
    '    custom_status="%{$fg_bold[red]%}PULL%{$reset_color%}|"'
    'elif [[ $remote == $base ]]; then'
    '    true'
    'else'
    '    custom_status="%{$fg_bold[red]%}DIVERGED%{$reset_color%}|"'
    'fi'
)

gss="$(which git_super_status)"
# Line number of STATUS="$ZSH
n="$(
    echo "$gss" |
    grep -n 'STATUS="\$ZSH' |
    awk '{print $1}' |
    cut -d ':' -f 1
)"

# Put each line of git_super_status() into lines
lines=()
while read -r line; do
    lines+=( "$line" )
done < <(echo "$gss")

new_line_n='STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$custom_status'
new_line_n+='$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"'

lines=(
    $lines[1,$((n-1))]        # Code before line n
    $new_status_def           # Pull & diverge status
    $new_line                 # Modified line n
    $lines[$((n+1)),$#lines]  # Code after line n
)

# Define the modified function
# Join lines with \n
eval "${(j:
:)lines}"
