{ config, pkgs, ... }:

{
  home = {
    username = "onirutla";
    homeDirectory = "/home/onirutla";
    stateVersion = "22.11";
    packages = with pkgs; [
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
	git = {
		enable = true;
		userName = "onirutlA";
		userEmail = "alturino001@gmail.com";
	};
	home-manager = {
		enable = true;
	};
    
  };
}
