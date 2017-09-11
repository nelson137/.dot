#!/bin/bash

hash tmux &> /dev/null || { echo "E: tmux is not installed"; exit 1; }

TMUX=''
args=( "$@" )

name="Temp"
nsplits="0"

for i in "${!args[@]}"; do
	if [[ ${args[$i]} == -n ]]; then
		name="${args[$((i+1))]}"
	elif [[ ${args[$i]} == -s ]]; then
		npanes="${args[$((i+1))]}"
	fi
done

tmux new -s "$name" -n "$name" -d

if [[ $npanes -lt 5 ]]; then
	if [[ $npanes == 2 ]]; then
		tmux splitw -t 0
	elif [[ $npanes == 3 ]]; then
		tmux splitw -t 0 -p 33
		tmux splitw -t 0
	elif [[ $npanes == 4 ]]; then
		tmux splitw -t 0
		tmux splitw -t 0
		tmux splitw -t 1
	fi
fi

tmux selectp -t 0
tmux a
