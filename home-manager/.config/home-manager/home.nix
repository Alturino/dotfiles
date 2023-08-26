{ config, pkgs, ... }:

{
  home = {
    username = "onirutla";
    homeDirectory = "/home/onirutla";
    stateVersion = "22.11";
    packages = with pkgs; [
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
      exa
    ];
  };

  programs = {
    
    home-manager = {
      enable = true;
    };
    
  };
}
