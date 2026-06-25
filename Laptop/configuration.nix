{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.linuxPackages;
    kernel.sysctl = { "net.core.default_qdisc" = "fq"; "net.ipv4.tcp_congestion_control" = "bbr"; };
    kernelParams = [ "quiet" "splash" "loglevel=3" ];
    plymouth = { enable = true; theme = "bgrt"; };
  };

  networking = { hostName = "nixos"; networkmanager.enable = true; };
  time.timeZone = "America/Caracas";
  i18n.defaultLocale = "es_MX.UTF-8";

  nix = {
    settings = { experimental-features = ["nix-command" "flakes"]; auto-optimise-store = true; };
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };
  };

  users.users.neny = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" "docker" "libvirtd" "adbusers" ];
  };

  services = {
    xserver = { enable = true; xkb = { layout = "latam"; }; };
    displayManager.sddm = { enable = true; autoLogin = { enable = true; user = "neny"; }; wayland.enable = true; };
    desktopManager.plasma6.enable = true;
    udisks2.enable = true;
    printing.enable = true;
  };

  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    adb.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [ 
      print-manager kinfocenter khelpcenter okular gwenview elisa plasma-systemmonitor 
    ];
    systemPackages = with pkgs; [
      brave cava htop onlyoffice-desktopeditors proton-vpn fastfetch vlc 
      spotify vscodium qbittorrent motrix android-tools mtkclient edl 
      idevicerestore localsend kdenlive partitionmanager isoimagewriter 
      davinci-resolve tor-browser obs-studio gimp discord
      nerd-fonts.jetbrains-mono (python3.withPackages (_: []))
    ];
  };
