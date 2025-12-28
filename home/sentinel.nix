{ config, pkgs, ... };

{
    home.username = "sentinel";
    home.homeDirectory = "/home/sentinel";
    home.stateVersion = "25.11";
    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo i use home-manager btw";
        };
    };

    home.packages = with pkgs; [
        git
        neovim
        wget
        curl
    ];

    # Let Home Manager manage itself
    programs.home-manager.enable = true;
}
