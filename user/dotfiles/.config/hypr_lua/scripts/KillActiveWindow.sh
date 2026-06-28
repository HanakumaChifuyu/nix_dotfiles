#! /usr/bin/env bash
active_pid=$(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)

kill -9 $active_pid
