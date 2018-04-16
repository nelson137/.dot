#!/bin/bash

dir="$(dirname $0)"

cat > "${dir}/.git/hooks/post-merge" <<EOF
#!/bin/bash

modified="\$(git diff-tree -r --diff-filter=M --no-commit-id ORIG_HEAD HEAD)"
modified="\$(echo "\$modified" | awk '{print \$6}')"

echo "\$modified" | grep "t.cpp" >/dev/null 2>&1 && {
    g++ t.cpp -std=c++11 -o t
}
EOF

chmod +x "${dir}/.git/hooks/post-merge"
