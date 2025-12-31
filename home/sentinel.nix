{ config, pkgs, ... }:

{
    home.username = "sentinel";
    home.homeDirectory = "/home/sentinel";
    home.stateVersion = "25.11";
    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo i use plasma btw";
            nxr = "sudo nixos-rebuild --impure switch --flake /home/sentinel/nixos-mitsuki#mitsuki";
        };
    };
    programs.onedrive.enable = true;

    home.packages = with pkgs; [
        git
        git-credential-manager
        neovim
        wget
        curl
        vscode
        onedrive
    ];

    # Let Home Manager manage itself
    programs.home-manager.enable = true;

    # Manage Git
    programs.git = {
        enable = true;
        settings.user.name  = "sentxd";
        settings.user.email = "sentxd@gmail.com";
	settings = {
          credential.helper = "store";
	};
    };
}
