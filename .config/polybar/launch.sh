#!/bin/bash


killall -q polybar

while pgrep -u $UID --exact polybar; do
    sleep 1
done

polybar -r top &
polybar -r bottom &
