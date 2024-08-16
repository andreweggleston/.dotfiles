{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
    };
    kernel.sysctl = {
      # enable packet forwarding
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;
      # block martian packets
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.lan0.rp_filter" = 1;
      "net.ipv4.conf.wan0.rp_filter" = 1;
      # ipv6 autoconfig on wan0
      "net.ipv6.conf.wan0.accept_ra" = 2;
      "net.ipv6.conf.wan0.autoconf" = 1;
    };
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200n8"
    ];
  };


  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4fd38275-3449-42de-9510-8f2e7cd339c6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1076-F1D4";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
