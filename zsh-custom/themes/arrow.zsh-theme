local ret_status="%(?:%{$fg_bold[green]%}\$ :%{$fg_bold[red]%}\$ )"
PROMPT='╭─ %{$fg[cyan]%}%~%{$reset_color%}
╰─ ${ret_status}%{$reset_color%}'
