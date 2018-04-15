#!/bin/bash

_cleanup() {
    stty echo
}
trap _cleanup EXIT

# Delete echo'd line
stty -echo
echo -n "some text that will be deleted"
echo -en "\b\b\b\b\b"
sleep 3
echo -e "\033[2K"
