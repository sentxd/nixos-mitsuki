{ config, pkgs, ... }:

{
    home.username = "sentinel";
    home.homeDirectory = "/home/sentinel";
    home.stateVersion = "25.11";
    home.language.base = "en_AU.UTF-8";
    home.language.time = "en_GB.UTF-8";

    programs.bash = {
        enable = true;
        shellAliases = {
            btw = "echo i use plasma btw";
            nxr = "sudo nixos-rebuild --impure switch --flake /home/sentinel/nixos-mitsuki#mitsuki";
            drb = "sudo nixos-rebuild --impure dry-build --flake /home/sentinel/nixos-mitsuki#mitsuki";
            nfu = "sudo nix flake update /home/sentinel/nixos-mitsuki";
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
        mpv
        signal-desktop
        kuro
        vlc
        evolution
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

    # KDE Symlinks
    home.file = {
        ".config/kdeglobals".source = /home/sentinel/nixos-mitsuki/dotfiles/kde/kdeglobals;
        ".config/kcminputrc".source = /home/sentinel/nixos-mitsuki/dotfiles/kde/kcminputrc;
        ".config/powerdevilrc".source = /home/sentinel/nixos-mitsuki/dotfiles/kde/powerdevilrc;
        ".config/powermanagementprofilesrc".source = /home/sentinel/nixos-mitsuki/dotfiles/kde/powermanagementprofilesrc;
        ".config/plasma-localerc".source = /home/sentinel/nixos-mitsuki/dotfiles/kde/plasma-localerc;
    };
    home.file.".config/kscreenlockerrc".text = ''
        [Greeter]
        Use24HourClock=true
    '';

}
