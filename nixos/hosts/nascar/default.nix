{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:

{
  imports = [
    ../../minimal.nix
    ./hardware-configuration.nix

    ./deluge.nix
    ./vpn.nix
    ./arr.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/nascar.nix;

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot";
      }
    ];
  };
  boot.zfs.extraPools = [ "tank" ];
  services.zfs.autoScrub.enable = true;

  networking = {
    hostName = "nascar"; # Define your hostname.
    hostId = "87c61ef6";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # unneeded when auto timesync is on
  # time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    smartmontools
    ipmitool
    ipmicfg
  ];

  # Distributed builds
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        system = "x86_64-linux";
        sshUser = "andreweggleston";
        sshKey = "/home/andreweggleston/.ssh/id_ed25519";
        hostName = "kilpisjarvi.${secrets.internal_domain}";
      }
    ];
    settings.trusted-users = [ "andreweggleston" ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  #  system.copySystemConfiguration = true;

  system.stateVersion = "25.05";
}
