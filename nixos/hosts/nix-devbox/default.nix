# Host config for 14" M1-Pro macbook pro 

{ config, pkgs, lib, inputs, outputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      
      ../../common.nix

      # enable various features
      ../../features/sound.nix

      # key mappings
      # outputs.nixosModules.dual-function-keys
      # ../../features/key-mapping/caps-to-ctrl-esc.nix
      # ../../features/key-mapping/right-alt-to-ctrl-b.nix

      # loopback video (for virtual webcam)
      # outputs.nixosModules.v4l2-loopback
    ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/nix-devbox.nix;

  # Webcam
  # v4l2-loopback = {
  #   enable = true;
  #   devices = [
  #     {
  #       number = 0;
  #       label = "Droidcam";
  #     }
  #   ];
  # };


  # services.speakersafetyd.enable = true;

  environment.systemPackages = [ 

  ];


  networking = {
    hostName = "nix-devbox";
	nameservers = ["192.168.2.2"];
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  system.stateVersion = "23.11";
}

