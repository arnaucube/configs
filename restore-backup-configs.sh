#!/usr/bin/env bash


cp ./init.vim ~/.config/nvim/init.vim
cp ./.vimrc ~/.vimrc
cp ./vimconfigbase.vim ~/vimconfigbase.vim
cp ./.tmux.conf ~/.tmux.conf
cp ./zathurarc ~/.config/zathura/zathurarc

mkdir -p ~/.config/sway
cp ./sway/config ~/.config/sway/config
cp ./sway/status.sh ~/.config/sway/status.sh

mkdir -p alacritty
cp ./alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
