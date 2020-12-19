#!/bin/zsh

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep; done

polybar mybar &
