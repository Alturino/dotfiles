{ config, pkgs, ... }:

{
  home = {
    username = "onirutla";
    homeDirectory = "/home/onirutla";
    stateVersion = "22.11";
    packages = with pkgs; [
      cmake
      fzf
      zsh
      vim
      neovim
      fish
      tmux
      htop
      neofetch
      lazygit
      speedtest-cli
      ripgrep
      gitui
      trash-cli
      bat
      zoxide
      starship 
      eza
    ];
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };
}
