{ config, pkgs, ... }:

{
    home.username = "sentinel";
    home.homeDirectory = "/home/sentinel";
    home.stateVersion = "25.11";
    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo i use vscode btw";
	    nxr = "sudo nixos-rebuild --impure switch --flake /home/sentinel/nixos-mitsuki#mitsuki";
        };
    };

    home.packages = with pkgs; [
        git
        neovim
        wget
        curl
        vscode
    ];

    # Let Home Manager manage itself
    programs.home-manager.enable = true;

    # Manage Git
    programs.git = {
        enable = true;
        settings.user.name  = "sentxd";
        settings.user.email = "sentxd@gmail.com";
    };
}
