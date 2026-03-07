# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../common.nix

    ../../features/sound.nix
    ../../features/bluetooth.nix

    ../../features/kde.nix
    # ../../features/i3.nix

    ../../features/podman.nix

    ../../features/steam.nix
    ../../features/sunshine.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/drew-pc.nix;

  services.xserver.videoDrivers = [ "nvidia" ];

  services.displayManager.autoLogin = {
    user = "andreweggleston";
    enable = true;
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "580.119.02";
        sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
        openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
        settingsSha256 = "sha256-VcCa3P/v3tDRzDgaY+hLrQSwswvNhsm93anmOhUymvM=";
        usePersistenced = false;
      };
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        nvidia-vaapi-driver
      ];
    };
  };
  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  networking.hostName = "drew-pc"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [
    25565
  ];
  networking.firewall.allowedUDPPorts = [
    25565
  ];

  # Set your time zone. Unnecessary if automatic-timezoned is enabled
  # time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable X11 forwarding for ssh clients who request it
  services.openssh.settings.X11Forwarding = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    let
      nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
    in
    lib.optionals nvidiaEnabled [
      (config.hardware.nvidia.package.settings.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.vulkan-headers ];
      }))
    ]
    ++ [
      pkgs.distrobox
    ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
