local ret_status="%(?:%{$fg_bold[green]%}\$ :%{$fg_bold[red]%}\$ )"
local user="%{$fg_bold[green]%}${USER}"
local at="%{$fg[cyan]%}@"
local host="%{$fg_bold[green]%}${HOST}"
local colon="%{$reset_color%}:"
local cwd="%{$fg[cyan]%}%~"

PROMPT='╭─ ${user}${at}${host}${colon}${cwd}
%{$reset_color%}╰─ ${ret_status}%{$reset_color%}'
