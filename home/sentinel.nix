{ config, pkgs, ... }:

# KDE Symlinks
let
  kdeDotfilesDir =
    "${config.home.homeDirectory}/nixos-mitsuki/dotfiles/kde";

  link = file:
    config.lib.file.mkOutOfStoreSymlink "${kdeDotfilesDir}/${file}";

  kdeFiles = [
    "kdeglobals"
    "kcminputrc"
    "powerdevilrc"
    "powermanagementprofilesrc"
    "plasma-localerc"
  ];
in
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
      vscode = "code";
      ll = "ls -la";
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
    mpv
    signal-desktop
    kuro
    vlc
    evolution
    evolution-ews
    google-chrome    
    caprine
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "sentxd";
      user.email = "sentxd@gmail.com";
      credential.helper = "store";
    };
  };

  # KDE Specific Configs
  xdg.configFile =
    builtins.listToAttrs (map (f: {
      name = f;
      value.source = link f;
    }) kdeFiles);

  home.file.".config/kscreenlockerrc".text = ''
    [Greeter]
    Use24HourClock=true
  '';
}
