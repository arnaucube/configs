# assumming that curl & wget & git & vim are already installed and this repo is downloaded

echo "updating"
apt-get update

# tmux
echo "installing tmux"
apt-get -y install tmux

echo "setting tmux config"
cp ./.tmux.conf ~/.tmux.conf

# vim
echo "setting vim config"
cp ./.vimrc ~/.vimrc
cp ./vimconfigbase.vim ~/vimconfigbase.vim

# neovim
echo "installing neovim"
# alternative: apt-get install python3-neovim
apt-get -y install neovim
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
## once Plug installed, execute inside nvim:
## :PlugInstall
## :GoInstallBinaries

# bash
cp .bash_alias ~/.bash_alias
echo "append .bashrc of this repo lines to the .bashrc system file"
cat .bashrc >> ~/.bashrc

source .bashrc

# go
echo "installing go 1.14.2"
wget https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.2.linux-amd64.tar.gz

# nodejs
echo "installing nodejs v14"
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs

echo "installing npm http-server"
npm install -g http-server

echo "installing fzf fuzzy finder"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "instaling ripgrep"
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb
dpkg -i ripgrep_11.0.2_amd64.deb

echo "install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# assuming that Rust is installed
echo "installing delta (gitdiff tool)"
cargo install git-delta
echo "append .gitconfig of this repo lines to the .gitconfig system file to use delta gitdiff tool"
cat .gitconfig >> ~/.gitconfig

# install gotty (for terminal visualization sharing)
wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
tar -zxvf gotty_linux_amd64.tar.gz
mv gotty /usr/gotty /usr/local/bin/

# nginx
apt install nginx -y

# certbot
apt-get update
apt-get install software-properties-common -y
add-apt-repository universe -y
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install certbot python-certbot-nginx -y
