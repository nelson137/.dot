#!/bin/bash

export PATH="$HOME/bin:$PATH"

source ~/.virtualenvs/MainEnv/bin/activate

if [ -f "$HOME/.bashrc" ]; then
	alias r="source $HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
	alias r="source $HOME/.bash_profile"
fi

# TODO:
# 	function to replace `rm <thing>` with `mv <thing> ~/.Trash`
# 	function to replace OSX `exit` with `exit` and quit teminal

mkcd() {
	if [ "$#" -ne "1" ]; then
		echo "E: mkcd can only take 1 argument: [dir]"
	else
		mkdir -p -- "$1" && cd -P -- "$1"
	fi
}

border() {
	if [ "$#" -gt "0" ]; then
		b="#"
		lines=("$@")
		widest="0"
		for l in "${lines[@]}"; do if [ "${#l}" -gt "$widest" ]; then widest="${#l}"; fi; done
		full_widest="$((widest+4))"
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
		for l in "${lines[@]}"; do
		width="${#l}"
		if [ "$width" != "$widest" ]; then
			echo "$b $l`printf ' %.0s' $(seq 1 $((widest-width)))` $b"
		else
			echo "$b $l $b"
		fi
		done
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
	else
		echo "E: border-text requires an array of lines to border"
	fi
}

mygpp() {
	if [ "$@" -ne "1" ]; then
		echo "E: mygpp can only take 1 argument: [input_file]"
	else
		g++ "$1" -o "${1%.cpp}"
	fi
}
