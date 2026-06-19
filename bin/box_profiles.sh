#!/usr/bin/env bash
#
# See `box` file for more details.

profile_minimal() {
    apt-get install -y neovim git curl wget
}

profile_rust() {
    apt-get install -y neovim git curl build-essential
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

profile_nodejs() {
    apt-get install -y curl
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
}

profile_docker() {
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

profile_dev_env() {
    git clone https://github.com/arnaucube/configs.git # includes rust
    cd configs
    yes | bash install-new-server.sh
}

profile_latex() {
    sudo apt install latexmk
    sudo apt install texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
}

profile_default() {
    profile_minimal
    profile_nodejs
    profile_docker
    profile_ai
    profile_dev_env # includes rust
    profile_latex
}
