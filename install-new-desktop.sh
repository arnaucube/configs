# this file assumes NixOS is being used using the NixOS configuration provided in this repo.


cp ./.tmux.conf ~/.tmux.conf

cp ./vimconfigbase.vim ~/vimconfigbase.vim
cp ./.vimrc ~/.vimrc

mkdir ~/.config
mkdir ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim

cp ./.zshrc ~/.zshrc
cp ./.sh_alias ~/.sh_alias

mkdir -p ~/bin
cp ./bin/ltx ~/bin/
cp ./bin/screens ~/bin/
cp ./bin/wk ~/bin/


# assuming that Rust is installed
echo "installing delta (gitdiff tool)"
cargo install git-delta
echo "append .gitconfig of this repo lines to the .gitconfig system file to use delta gitdiff tool"
cat .gitconfig >> ~/.gitconfig
