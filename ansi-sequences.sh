#!/bin/bash

echo abc
echo def
printf '\033[s'  # save pos
printf '\033[2A'  # up one line to col 0. 3A is 2 lines
printf '\033[2C'  # forward 2
printf 0
printf '\033[u'  # restore pos
