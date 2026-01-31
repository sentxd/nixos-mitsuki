{ config, pkgs, ... }:

# Symlinks
let
  mkLink = baseDir: file:
    config.lib.file.mkOutOfStoreSymlink "${baseDir}/${file}";

  # KDE Dotfiles
  kdeDotfilesDir = "${config.home.homeDirectory}/nixos-mitsuki/dotfiles/kde";
  linkKde = mkLink kdeDotfilesDir;

  kdeFiles = [
    "kdeglobals"
    "kcminputrc"
    "powerdevilrc"
    "powermanagementprofilesrc"
    "plasma-localerc"
    "kglobalshortcutsrc"
  ];

  kdeAttrs = builtins.listToAttrs (map (f: {
    name = f;
    value.source = linkKde f;
  }) kdeFiles);

  # fcitx5 configuration
  fcitx5DotfilesDir = "${config.home.homeDirectory}/nixos-mitsuki/dotfiles";
  linkFcitx5 = mkLink fcitx5DotfilesDir;

  # These names are RELATIVE TO ~/.config/
  # so "fcitx5/profile" becomes ~/.config/fcitx5/profile
  fcitx5Files = [
    "fcitx5/profile"
    "fcitx5/config"
    "fcitx5/conf/mozc.conf"
  ];

  fcitx5Attrs = builtins.listToAttrs (map (f: {
    name = f;
    value.source = linkFcitx5 f;
  }) fcitx5Files);

in
{
  # XDG Configuration 
  xdg.configFile = kdeAttrs // fcitx5Attrs;

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
      nfu = "nix flake update --flake /home/sentinel/nixos-mitsuki";
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
    google-chrome    
    caprine
    gnome-online-accounts
    gnome-online-accounts-gtk
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
  home.file.".config/kscreenlockerrc".text = ''
    [Greeter]
    Use24HourClock=true
  '';
}
