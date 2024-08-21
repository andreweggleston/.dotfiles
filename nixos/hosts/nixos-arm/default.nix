{ config, lib, pkgs, inputs, outputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../../common.nix
    ];
  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/nixos-arm.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-arm"; # Define your hostname.

  time.timeZone = "America/New_York";

  environment.systemPackages = [
  ];

  system.stateVersion = "24.05"; # Did you read the comment?

}

