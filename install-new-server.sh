# assumming that git & vim are already installed and this repo is downloaded

echo "updating"
sudo apt-get update

# tmux
echo "installing tmux"
sudo apt-get -y install tmux

echo "setting tmux config"
cp ./.tmux.conf ~/.tmux.conf

# vim
echo "setting vim config"
cp ./.vimrc ~/.vimrc

# neovim
echo "installing neovim"
sudo apt-get -y install neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "setting nvim config"
mkdir ~/.config
mkdir ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim

# vim & neovim PlugInstall
echo "installing PlugInstall vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "installing PlugInstall neovim"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# bash
echo "append .bashrc of this repo lines to the .bashrc system file"
cat ../.bashrc >> ~/.bashrc

source .bashrc

# go
echo "installing go 1.11.5"
wget https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz

# nodejs
echo "installing nodejs v8"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "installing npm http-server"
sudo npm install -g http-server
