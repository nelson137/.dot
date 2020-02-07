#!/bin/bash


killall -q polybar

while pgrep -u $UID --exact polybar; do
    sleep 1
done

for m in $(polybar -m | cut -d: -f1); do
    MONITOR="$m" polybar -r top & disown
    MONITOR="$m" polybar -r bottom & disown
done
