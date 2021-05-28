FROM ubuntu:20.04

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y \
    apt-utils \
    build-essential \
    wget \
    curl \
    git \
    neovim \
    vim && \
    apt-get clean

RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install go
RUN wget https://golang.org/dl/go1.16.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz

RUN echo "export PATH=$PATH:/usr/local/go/bin" >> ./bashrc
RUN echo "export GOPATH=$HOME/go" >> ./bashrc

RUN git clone https://github.com/arnaucube/configs.git && \
    cp configs/.vimrc ~/ && \
    cp configs/vimconfigbase.vim ~/ && \
    mkdir ~/.config && \
    mkdir ~/.config/nvim && \
    cp configs/init.vim ~/.config/nvim/

WORKDIR /root

ENTRYPOINT /bin/sh
