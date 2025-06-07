#!/bin/sh

curr=$(setxkbmap -print | awk -F"+" '/xkb_symbols/ {print $2}')

if [[ $curr = "us" ]];
then
	setxkbmap -layout es -variant ',cat' -option
	echo "keyboard layout set to Catalan"
else
	setxkbmap -layout us -option
	echo "keyboard layout set to English (US)"
fi

xmodmap ~/.Xmodmap
