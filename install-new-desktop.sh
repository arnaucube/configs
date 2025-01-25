# this file assumes NixOS is being used using the NixOS configuration provided in this repo.


cp ./.tmux.conf ~/.tmux.conf

cp ./vimconfigbase.vim ~/vimconfigbase.vim
cp ./.vimrc ~/.vimrc

mkdir -p ~/.config
mkdir -p ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim

cp ./.zshrc ~/.zshrc
cp ./.sh_alias ~/.sh_alias

mkdir -p ~/bin
cp -r ./bin/* ~/bin/

cp -r ./alacritty ~/.config/
cp -r ./i3status ~/.config/

mkdir -p ~/.config/zathura
cp ./zathurarc ~/.config/zathura/


# assuming that Rust is installed
echo "append .gitconfig of this repo lines to the .gitconfig system file to use delta gitdiff tool"
cat .gitconfig >> ~/.gitconfig
