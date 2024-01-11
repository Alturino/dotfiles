sudo dnf config-manager --save --setopt=fastestmirror=True
sudo dnf update -y
sudo dnf install alacritty -y
sudo dnf install clang -y
sudo dnf install cmake -y
sudo dnf install eza -y
sudo dnf install fzf -y 
sudo dnf install gcc-c++ -y
sudo dnf install htop -y
sudo dnf install neovim -y
sudo dnf install nodejs -y
sudo dnf install python -y
sudo dnf install ripgrep -y
sudo dnf install stow -y
sudo dnf install syncthing -y
sudo dnf install tmux -y
sudo dnf install vim -y
sudo dnf install zoxide -y
sudo dnf install zsh -y

#Install ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install Jetbrains Toolbox
# cd /opt/
# sudo tar -xvzf ~/Downloads/jetbrains-toolbox-2.1.2.18853.tar.gz
# sudo mv jetbrains-toolbox-2.1.2.18853 jetbrains

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME"/.cargo/env

# Install Go
 sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
 sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
 export PATH=$PATH:/usr/local/go/bin
 go version

# Clone dotfiles
git clone https://github.com/onirutlA/dotfiles
