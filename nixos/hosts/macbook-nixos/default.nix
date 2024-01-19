# Host config for 14" M1-Pro macbook pro 

{ config, pkgs, lib, inputs, outputs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # apple-silicon hardware support
      inputs.apple-silicon.nixosModules.apple-silicon-support

      # speakersafetyd module from this repo
      outputs.nixosModules.speakersafetyd
      
      ../../common.nix

      # enable various features
      ../../features/sound.nix
      ../../features/bluetooth.nix
      ../../features/sway.nix

      # font config
      ../../features/hidpi.nix

      # printing
      ../../features/printing.nix

      # key mappings
      # outputs.nixosModules.dual-function-keys
      # ../../features/key-mapping/caps-to-ctrl-esc.nix
      # ../../features/key-mapping/right-alt-to-ctrl-b.nix

      # loopback video (for virtual webcam)
      # outputs.nixosModules.v4l2-loopback

      # iam scared of my speakers exploding
      #./enable-speakers.nix
    ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/macbook-nixos.nix;

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

  environment.systemPackages = [ ];


  # asahi linux overlay
  # nixpkgs.overlays = [ inputs.apple-silicon.overlays.apple-silicon-overlay ];

  # enable GPU support
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.experimentalGPUInstallMode = "replace";
  hardware.asahi.addEdgeKernelConfig = true;
  hardware.asahi.withRust = true;
  hardware.asahi.setupAlsaUcm = true;

  # backlight control
  programs.light.enable = true;  
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
    ];
  };

  # use TLP for power management
  services.tlp = {
    enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "macbook-nixos"; # Define your hostname.
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  system.stateVersion = "23.11";
}

