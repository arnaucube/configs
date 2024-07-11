# assumming that git is already installed and this repo is installed

echo "updating"
sudo apt-get update

echo "installing neovim"
sudo apt-get -y install neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "installing tmux"
sudo apt-get -y install tmux

echo "setting nvim config"
mkdir ~/.config
mkdir ~/.config/nvim
cp ../init.vim ~/.config/nvim/init.vim

echo "setting xmodmap config"
cp ../.Xmodmap ~/.Xmodmap
xmodmap ~/.Xmodmap

echo "setting tmux config"
cp ../.tmux.conf ~/.tmux.conf

echo "append .bashrc of this repo lines to the .bashrc system file"
cat ../.bashrc >> ~/.bashrc

# Additionally, fix the IP:
# vim /etc/dhcpcd.conf:
#
# interface eth0
# static ip_address=192.168.1.150/24
# static routers=192.168.1.1
# static domain_name_servers=192.168.1.1

# UPDATE: in newer systems (ie. raspbian on rpi5):
# vim /etc/network/interfaces:
#
# auto eth0
# iface eth0 inet static
#     address 192.168.1.150
#     netmask 255.255.255.0
#     gateway 192.168.1.1
#     dns-nameservers 192.168.1.1
#
# and then restart the network interfaces with:
# sudo systemctl restart networking
