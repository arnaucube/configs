# assumming that curl & wget & git & vim are already installed and this repo is downloaded

echo "updating"
apt update

# tmux
echo "installing tmux"
apt -y install tmux

echo "setting tmux config"
cp ./.tmux.conf ~/.tmux.conf

echo "installing mosh"
apt -y install mosh

# vim
echo "setting vim config"
cp ./.vimrc ~/.vimrc
cp ./vimconfigbase.vim ~/vimconfigbase.vim

# neovim
echo "installing neovim"
# alternative: apt install python3-neovim
apt -y install neovim

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
cp .sh_alias ~/.sh_alias
echo "append .bashrc of this repo lines to the .bashrc system file"
cat .bashrc >> ~/.bashrc

source .bashrc

# # go
# echo "installing go 1.24.3"
# wget https://golang.org/dl/go1.24.3.linux-amd64.tar.gz
# tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
# 
# # nodejs
# echo "installing nodejs v16"
# # curl -sL https://deb.nodesource.com/setup_16.x | bash -
# curl -fsSL https://deb.nodesource.com/setup_21.x | bash -
# apt install -y nodejs
# 
# echo "installing npm http-server"
# npm install -g http-server

echo "installing fzf fuzzy finder"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

echo "instaling ripgrep"
# curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
# dpkg -i ripgrep_13.0.0_amd64.deb
apt install ripgrep -y

echo "install Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# needed for later rust packages installations
apt install build-essential -y
apt install pkg-config libssl-dev -y

# btop
# wget https://github.com/aristocratos/btop/releases/download/v1.3.0/btop-x86_64-linux-musl.tbz
# tar -xjf btop-x86_64-linux-musl.tbz
# cd btop
# bash install.sh
# cd ..

# # assuming that Rust is installed
# echo "installing delta (gitdiff tool)"
# cargo install git-delta
# echo "append .gitconfig of this repo lines to the .gitconfig system file to use delta gitdiff tool"
# cat .gitconfig >> ~/.gitconfig
# 
# # install gotty (for terminal visualization sharing)
# wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz
# tar -zxvf gotty_linux_amd64.tar.gz
# mv gotty /usr/gotty /usr/local/bin/
# 
# # nginx
# apt install nginx -y
# 
# # certbot
# apt update
# apt-get install software-properties-common -y
# add-apt-repository universe -y
# add-apt-repository ppa:certbot/certbot -y
# apt-get update
# apt-get install certbot python-certbot-nginx -y
