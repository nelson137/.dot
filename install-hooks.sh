#!/bin/bash

hooks="$(cd "$(dirname "$0")" && pwd)/.git/hooks"

# Make sure the hooks directory exists
mkdir -p "$hooks"

# Remove all example hooks
rm -f "$hooks"/*.sample

pushd "$hooks" >/dev/null

# Symbolic link the hooks
command ls -A '../../hooks' | xargs -I % ln -fs '../../hooks/%' .

popd >/dev/null
