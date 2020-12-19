#!/bin/sh
xrandr --auto
xrandr --output HDMI-2 --above eDP-1
xrandr --output DP-1 --left-of HDMI-2
