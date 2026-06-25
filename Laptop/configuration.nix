{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    initrd.kernelModules = [ "i915" ];
    kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [ "quiet" "splash" "loglevel=0" "rd.systemd.show_status=false" "rd.udev.log_priority=3" "udev.log_priority=3" "vt.global_cursor_default=0" ];
    plymouth = { enable = true; theme = "bgrt"; };
  };

  hardware.graphics.enable = true;

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };
  };

  time.timeZone = "America/Caracas";
  i18n.defaultLocale = "es_MX.UTF-8";

  nix = {
    settings = { experimental-features = [ "nix-command" "flakes" ]; auto-optimise-store = true; };
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };
  };

  users.users.neny = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" "docker" "libvirtd" "adbusers" ];
  };

  services = {
    xserver = { enable = true; xkb.layout = "latam"; };
    displayManager = {
      sddm = { enable = true; wayland.enable = true; };
      autoLogin = { enable = true; user = "neny"; };
    };
    desktopManager.plasma6.enable = true;
    udisks2.enable = true;
    printing.enable = true;
    flatpak.enable = true;
  };

  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [ print-manager kinfocenter khelpcenter okular gwenview elisa plasma-systemmonitor ];
    systemPackages = with pkgs; [
      (python3.withPackages (_: []))
      kdePackages.partitionmanager
      kdePackages.isoimagewriter
      nerd-fonts.jetbrains-mono
      onlyoffice-desktopeditors
      davinci-resolve
      idevicerestore
      android-tools
      tor-browser
      metasploit
      obs-studio
      proton-vpn
      fastfetch
      mtkclient
      localsend
      vscodium
      wifite2
      discord
      spotify
      motrix
      jdk25
      brave
      gimp
      cava
      htop
      vlc
      edl
    ];
  };
}
