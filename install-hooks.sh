#!/bin/bash

dir="$(dirname $0)"

cat > "${dir}/.git/hooks/post-merge" <<EOF
#!/bin/bash

dir="\$(dirname \$0)"

url="https://raw.githubusercontent.com/nelson137/Brainfuck/master/interpreters/brainfuck.cpp"
curl -sS "\$url" -o "\${dir}/brainfuck.cpp"
g++ -std=c++11 "\${dir}/brainfuck.cpp" -o "\${dir}/bin/brainfuck"
rm "\${dir}/brainfuck.cpp"
EOF

chmod +x "${dir}/.git/hooks/post-merge"
