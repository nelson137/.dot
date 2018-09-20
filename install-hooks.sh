#!/bin/bash

hooks="$(dirname "$0")/.git/hooks"

# Make sure the hooks directory exists
mkdir -p "$hooks"

# Remove all example hooks
rm -f "${hooks}"/*.sample

cd "$hooks"
# Symbolic link the hooks
command ls -A '../../hooks' | xargs -I % ln -fs '../../hooks/%' .
