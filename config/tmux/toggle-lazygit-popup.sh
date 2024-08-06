#!/usr/bin/env bash
#
# Source: https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/
#
# TODO: investigate other options that don't create sessions:
#   - https://unix.stackexchange.com/questions/145857/how-do-you-hide-a-tmux-pane
#   - https://www.reddit.com/r/tmux/comments/olgte7/floating_popups_in_tmux/

current_session="$(tmux display -p '#S')"
lazygit_session="${current_session}#lazygit"

if ! tmux has -t "$lazygit_session" 2> /dev/null; then
  session_id="$(tmux new-session -ds "$lazygit_session" -PF '#{session_id}' lazygit)"
  tmux set-option -s -t "$session_id" key-table popup-lazygit
  tmux set-option -s -t "$session_id" status off
  tmux set-option -s -t "$session_id" prefix None
  lazygit_session="$session_id"
fi

exec tmux attach -t "$lazygit_session" >/dev/null
