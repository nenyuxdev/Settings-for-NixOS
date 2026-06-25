{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = { systemd-boot.enable = true; efi.canTouchEfiVariables = true; };
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "vm.max_map_count" = 2147483642;
      "vm.swappiness" = 10;
      "fs.file-max" = 2097152;
    };

    initrd.kernelModules = [ "amdgpu" ];

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
      "vt.global_cursor_default=0"
      "pcie_aspm=off"
      "processor.max_cstate=1"
      "amdgpu.ppfeaturemask=0xffffffff"
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

  systemd.services.lactd = {
    description = "AMDGPU Control Daemon";
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
      Nice = -10;
    };
  };

  services = {
    irqbalance.enable = true;
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
      extraArgs = [ "-m" "gaming" ];
    };
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    xserver = { enable = true; xkb = { layout = "latam,es,us"; variant = ""; }; };

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
  };

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
    gamescope.enable = true;
  };

  security.pam.loginLimits = [
    { domain = "@wheel"; item = "nice"; type = "-"; value = "-20"; }
    { domain = "@wheel"; item = "rtprio"; type = "-"; value = "99"; }
    { domain = "@wheel"; item = "nofile"; type = "-"; value = "1048576"; }
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
  console.keyMap = "es";
  powerManagement.cpuFreqGovernor = "performance";

  users.users.neny = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "audio" "video" "input"];
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

  hardware.graphics.enable = true;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.11";

  environment = {
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-systemmonitor print-manager kwalletmanager kinfocenter khelpcenter
      kwallet-pam gwenview okular kwallet elisa
    ];

    systemPackages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.steam-rom-manager
      pkgs.retroarch-assets
      pkgs.input-remapper
      pkgs.protonup-qt
      pkgs.dolphin-emu
      pkgs.obs-studio
      pkgs.fastfetch
      pkgs.retroarch
      pkgs.mangohud
      pkgs.discord
      pkgs.ryubing
      pkgs.spotify
      pkgs.heroic
      pkgs.lutris
      pkgs.ppsspp
      pkgs.brave
      pkgs.pcsx2
      pkgs.jdk25
      pkgs.lact
      pkgs.htop
    ];
  };
}
