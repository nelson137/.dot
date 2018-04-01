#local ret_status="%(?:%{$fg_bold[green]%}\$ :%{$fg_bold[red]%}\$ )"
#local commits_ahead=$(git status | grep -oE "[0-9]+ commits" | awk '{print $1}')
#[[ -n $commits_ahead ]] && commits_ahead=" ${commits_ahead}c"
#
#ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
#ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$fg[blue]%}${commits_ahead})"
#ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}${commits_ahead})"
#ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
#
#PROMPT='╭─ %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)
#╰─ ${ret_status}%{$reset_color%}'



local ret_status="%(?:%{$fg_bold[green]%}\$ :%{$fg_bold[red]%}\$ )"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$fg[blue]%}${commits_ahead})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}${commits_ahead})"

if git rev-parse --git-dir >/dev/null 2>&1; then
    # show number of commits ahead
    local ca=$(git status | grep -oE "[0-9]+ commits" | awk '{print $1}')
    [[ -n $ca ]] && ZSH_THEME_GIT_PROMPT_AHEAD=" ${ca}c"
fi

PROMPT='╭─ %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)
╰─ ${ret_status}%{$reset_color%}'
