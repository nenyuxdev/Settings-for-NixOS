{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot = { 
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; }; 
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    initrd.systemd.enable = true;
  };

  systemd.settings = {
    Manager = {
      DefaultCPUAccounting = true;
      DefaultMemoryAccounting = true;
      DefaultIOAccounting = true;
    };
  };

  systemd.services.display-manager.restartIfChanged = false;

  services = {
    packagekit.enable = true;
    scx = { 
      enable = true; 
      scheduler = "scx_bpfland"; 
      extraArgs = ["--primary-domain" "all" "--timely"]; 
    };
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    flatpak.enable = true;
    resolved = { 
      enable = true; 
      settings.Resolve = { 
        DNSSEC = "true"; 
        DNSOverTLS = "true"; 
        Domains = ["~."]; 
        FallbackDNS = ["1.1.1.1" "8.8.8.8"]; 
      }; 
    };
    xserver = { enable = true; xkb = { layout = "latam,es,us"; variant = ""; }; };
    
    # --- CONFIGURACIÓN CORREGIDA ---
    displayManager = {
      autoLogin = {
        enable = true;
        user = "neny";
      };
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    desktopManager.plasma6.enable = true;
    udisks2.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [ "git" "sudo" "docker" ];
      };
    };
    steam.enable = true; 
    dconf.enable = true; 
    kdeconnect.enable = true;
  };
  
  users.defaultUserShell = pkgs.zsh;

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "nice"; type = "-"; value = "-20"; }
    { domain = "@wheel"; item = "rtprio"; type = "-"; value = "99"; }
  ];

  networking = { 
    hostName = "nixos"; 
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };
  
  qt = { enable = true; platformTheme = "kde"; };

  time.timeZone = "America/Caracas";
  i18n = { 
    defaultLocale = "es_MX.UTF-8"; 
    extraLocaleSettings = { 
      LC_ADDRESS="es_VE.UTF-8"; LC_IDENTIFICATION="es_VE.UTF-8"; 
      LC_MEASUREMENT="es_VE.UTF-8"; LC_MONETARY="es_VE.UTF-8"; 
      LC_NAME="es_VE.UTF-8"; LC_NUMERIC="es_VE.UTF-8"; 
      LC_PAPER="es_VE.UTF-8"; LC_TELEPHONE="es_VE.UTF-8"; 
      LC_TIME="es_VE.UTF-8"; 
    }; 
  };
  console.keyMap = "la-latin1";
  powerManagement.cpuFreqGovernor = "performance";

  users.users.neny = { 
    isNormalUser = true; 
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "audio" "video" "input" "docker" "libvirtd"]; 
  };

  nix = { 
    settings = { 
      experimental-features = ["nix-command" "flakes"]; 
      auto-optimise-store = true; 
      substituters = ["https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    }; 
    gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; }; 
  };
  
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [ 
      print-manager kinfocenter khelpcenter okular gwenview elisa plasma-systemmonitor
    ];
    
    systemPackages = [
      pkgs.jdk25
      pkgs.pipes-rs
      pkgs.tty-clock
      pkgs.brave 
      pkgs.cava 
      pkgs.htop 
      pkgs.onlyoffice-desktopeditors 
      pkgs.proton-vpn 
      pkgs.heroic 
      pkgs.lutris 
      pkgs.protonup-qt
      pkgs.fastfetch 
      pkgs.vlc 
      pkgs.spotify 
      pkgs.vscodium 
      pkgs.prismlauncher 
      pkgs.qbittorrent 
      pkgs.motrix
      pkgs.android-tools 
      pkgs.mtkclient 
      pkgs.edl 
      pkgs.idevicerestore 
      pkgs.localsend
      pkgs.kdePackages.qtstyleplugin-kvantum
      pkgs.kdePackages.kdenlive
      pkgs.kdePackages.partitionmanager
      pkgs.kdePackages.isoimagewriter
      pkgs.kdePackages.sddm-kcm
      pkgs.reaper
      pkgs.davinci-resolve
      pkgs.tor-browser
      pkgs.obs-studio
      pkgs.gimp
      pkgs.blender
      pkgs.discord
      pkgs.zapzap
      pkgs.nerd-fonts.jetbrains-mono
      (pkgs.python3.withPackages (_: []))
    ];
  };
}
