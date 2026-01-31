# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "mitsuki"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # DISPLAYLINK
  # Prerequisite to download the synaptic displaylink drivers before this will build
  # nix-prefetch-url --name displaylink-620.zip https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip
  # The error logs will be printed to stdout when enabling displaylink drivers below in services.xserver.videoDrivers
  # Required for DisplayLink
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Needed for USB graphics devices
  hardware.graphics.enable = true;

  # Make sure evdi can build against your kernel
  boot.extraModulePackages = with config.boot.kernelPackages; [
    evdi
  ];

  # Optional but recommended
  hardware.enableRedistributableFirmware = true;
  # DISPLAYLINK END #

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Japanese input method (for typing Japanese characters)
  # i18n.inputMethod.enabled = with pkgs.lib; [ fcitx5 fcitx5-mozc ];
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      kdePackages.fcitx5-configtool
    ];
  };


  # SERVICES
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5900 445 ]; # SSH and VNC
    allowedUDPPorts = [ ];
  };
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Firmware Update
  services.fwupd.enable = true; 

  # Fingerprint reader
  services.fprintd = {
    enable = true;
    # tod.enable = true;
    # tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  # No fingerprint for console login or sudo.
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth  = true;
    sddm.fprintAuth  = false;
  };
  # Enable fingerprint ONLY for the Plasma lock screen
  security.pam.services.kde-fingerprint = {
    fprintAuth = true;  # fingerprint unlock
    unixAuth   = true;  # keep password fallback
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };

  # Enable Avahi for network device discovery.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Power management settings to disable hibernate, ignore lid close etc.
  services.logind = {
    settings.Login.HandlePowerKey = "suspend";
    settings.Login.HandleLidSwitch = "ignore";
    settings.Login.HandleLidSwitchExternalPower = "ignore";
    settings.Login.HandleLidSwitchDocked = "ignore";
    settings.Login.HandleHibernateKey = "ignore";
    settings.Login.HibernateDelaySec = 0;
    settings.Login.AllowHibernation = false;
    settings.Login.IdleAction = "ignore";
    settings.Login.IdleActionSec = 0;
  };

  systemd.sleep.extraConfig = ''
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # Samba file sharing service
  services.samba = {
    enable = true;

    # Windows-compatible defaults
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Samba Server";
        "security" = "user";
        "map to guest" = "never";
      };
      "Shared" = {
        "path" = "/home/sentinel/Shared";
        "browseable" = "yes";
        "read only" = "no";
        "valid users" = [ "sentinel" ];
      };
    };
  };

  # enable gnome-keyring for KDE
  services.gnome.gnome-keyring.enable = true;

  # Enable GNOME Online Accounts integration
  services.gnome.gnome-online-accounts.enable = true;

  # PAM integration so the keyring actually starts on login
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  ## PROGRAMS AND PACKAGES
  # Install Evolution with EWS plugin
  # programs.evolution = {
  #   enable = true;
  #   plugins = [ pkgs.evolution-ews ];
  # };

  # Enable dconf support for KDE applications
  programs.dconf.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Install thunderbird.
  # programs.thunderbird.enable = true;

  # Enable niri
  # programs.niri.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # recommended: allow your user to authorize privileged actions via polkit
    polkitPolicyOwners = [ "sentinel" ];
  };

  # Allow some insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    # Ventoy is marked insecure due to bundled binary blobs
    # See: https://github.com/NixOS/nixpkgs/issues/404663
    "ventoy-qt5-1.1.10"
  ];

  # Enable VMware Host support to install VMWare Workstation Pro
  virtualisation.vmware.host.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    inetutils
    git
    qemu_kvm
    virt-manager
    swtpm
    microsoft-edge
    (writeShellScriptBin "microsoft-edge-stable" ''
      exec ${pkgs.microsoft-edge}/bin/microsoft-edge "$@"
    '')
    p3x-onenote
    dnsmasq
    vscode
    ghostty
    tree
    bat
    tealdeer
    neofetch
    displaylink
    usbutils
    noto-fonts-cjk-sans
    onedriver
    # niri-related packages
    # foot # terminal for niri
    # waybar # status bar for niri
    # mako # notifications for niri
    ventoy-full-qt
    ripgrep
    ripgrep-all
  ];

  # Virtualisation
    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu = {
      swtpm.enable = true;
    };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ## USER
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sentinel = {
    isNormalUser = true;
    description = "Sentinel";
    extraGroups = [ "libvirtd" "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
