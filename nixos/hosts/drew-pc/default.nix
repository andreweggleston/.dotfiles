# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../common.nix

    ../../features/sound.nix
    ../../features/bluetooth.nix

    ../../features/kde.nix
    # ../../features/i3.nix

    ../../features/kvm.nix

    ../../features/steam.nix
    ../../features/sunshine.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/drew-pc.nix;

  services.xserver.videoDrivers = ["nvidia"];

  services.flatpak.enable = true;

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
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
  environment.systemPackages = let
    nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
  in
    lib.optionals nvidiaEnabled [
      (config.hardware.nvidia.package.settings.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [pkgs.vulkan-headers];
      }))
    ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
