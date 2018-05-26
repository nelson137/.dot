# vim:syntax=zsh

local new_status_def=(
    'local local_="$(git rev-parse @)"'
    'local url="$(git remote get-url origin)"'
    "local remote=\"\$(git ls-remote \"\$url\" | awk '/HEAD/ {print \$1}')\""
    'local base="$(git merge-base @ @{u})"'
    ''
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
n="$(echo "$gss" | grep -n 'STATUS="\$ZSH' | awk '{print $1}' | cut -d ":" -f 1)"

# Put each line of the git_super_status function into array lines
lines=()
while read -r line; do
    lines+=( "$line" )
done < <(echo "$gss")

new_line='STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$custom_status'
new_line+='$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"'

# Replace line $n with new_status_def and modified line $n
lines=( $lines[1,$((n-1))] $new_status_def $new_line $lines[$((n+1)),$#lines] )
# Define the modified function
eval "${(j:
:)lines}"
