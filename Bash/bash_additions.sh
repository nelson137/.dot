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
	if [[ $# != 1 ]]; then
		echo "Usage: mkcd DIR"
	else
		mkdir -p -- "$1" && cd -P -- "$1"
	fi
}

border() {
	if [[ $# > 0 ]]; then
		b="#"
		lines=("$@")
		widest="0"
		for l in "${lines[@]}"; do
			if [[ ${#l} > $widest ]]; then widest="${#l}"; fi
		done
		full_widest="$((widest+4))"
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
		for l in "${lines[@]}"; do
		width="${#l}"
		if [[ $width != $widest ]]; then
			echo "$b $l`printf ' %.0s' $(seq 1 $((widest-width)))` $b"
		else
			echo "$b $l $b"
		fi
		done
		echo $(printf -- "$b%.0s" $(seq 1 $full_widest))
	else
		echo "Usage: border STRING_ARRAY"
	fi
}

mygpp() {
	if [[ $# != 1 ]]; then
		echo "Usage: mygpp FILE"
	else
		g++ "$1" -o "${1%.cpp}"
	fi
}

qmygpp() {
	if [[ $# != 1 ]]; then
		echo "Usage: qmygpp FILE"
	else
		bin="${1%.cpp}"
		mygpp "$1"
		"./$bin"
		rm "./$bin"
	fi
}
