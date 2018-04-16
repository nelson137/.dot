#!/bin/bash

dir="$(dirname $0)"

cat > "${dir}/.git/hooks/post-merge" <<EOF
#!/bin/bash

dir="\$(dirname \$0)"

modified="\$(git diff-tree -r --diff-filter=M --no-commit-id ORIG_HEAD HEAD)"
modified="\$(echo "\$modified" | awk '{print \$6}')"

echo "\$modified" | grep "t.cpp" >/dev/null 2>&1 && {
    url="https://raw.githubusercontent.com/nelson137/Brainfuck/master/interpreters/brainfuck.cpp"
    curl -sS -o "\${dir}/brainfuck.cpp" "\$url"
    g++ "\${dir}/brainfuck.cpp" -o "\${dir}/bin/brainfuck" -std=c++11
    rm "\${dir}/brainfuck.cpp"
}
EOF

chmod +x "${dir}/.git/hooks/post-merge"
