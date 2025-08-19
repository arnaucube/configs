#!/usr/bin/env bash


cp ~/.config/nvim/init.vim ./init.vim
cp ~/.vimrc ./.vimrc
cp ~/vimconfigbase.vim ./vimconfigbase.vim
cp ~/.tmux.conf ./.tmux.conf

mkdir -p sway
cp ~/.config/sway/config ./sway/config
cp ~/.config/sway/status.sh ./sway/status.sh

mkdir -p alacritty
cp ~/.config/alacritty/alacritty.toml ./alacritty/alacritty.toml
