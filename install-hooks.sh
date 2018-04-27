#!/bin/bash

dir="$(dirname $0)"

cat > "${dir}/.git/hooks/post-merge" <<EOF
#!/bin/bash

dir="\$(dirname \$0)"

url="https://raw.githubusercontent.com/nelson137/Brainfuck/master/interpreters/brainfuck.cpp"
curl -sS "\$url" -o "\${dir}/brainfuck.cpp"
g++ -std=c++11 "\${dir}/brainfuck.cpp" -o "\${dir}/bin/brainfuck"
rm "\${dir}/brainfuck.cpp"

last_pull="\${dir}/last_pull"
current="\$(git rev-parse HEAD)"

git diff "\$(< \$last_pull)" "\$current" files/vimrc |
    egrep "^(\\+|-)" | egrep -v "^(\\+|-){3}" |
    egrep "Plugin (\\".+\\"|'.+')"

[[ \$? == 0 ]] && vim +PluginClean! +PluginInstall +qall

echo "\$current" > "\$last_pull"
EOF

chmod +x "${dir}/.git/hooks/post-merge"
