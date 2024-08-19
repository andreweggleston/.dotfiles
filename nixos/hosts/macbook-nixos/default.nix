{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  secrets,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # apple-silicon hardware support
    inputs.apple-silicon.nixosModules.apple-silicon-support

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

  environment.systemPackages = [
    pkgs.networkmanagerapplet
  ];

  # asahi linux overlay
  nixpkgs.overlays = [inputs.apple-silicon.overlays.apple-silicon-overlay];

  # enable GPU support
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.experimentalGPUInstallMode = "replace";

  # new sound option
  hardware.asahi.setupAsahiSound = true;

  # backlight control
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [225];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -A 10";
      }
      {
        keys = [224];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -U 10";
      }
    ];
  };

  # use TLP for power management
  services.tlp = {
    enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking = {
    hostName = "macbook-nixos";
    wireless = {
      iwd = {
        enable = true;
        settings.General.EnableNetworkConfiguration = true;
      };
    };
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      plugins = [
      ];
    };
    wireguard = {
      interfaces = {
        wg0 = let
          vpnNet = secrets.hosts.router.networks.vpn;
          lanNet = secrets.hosts.router.networks.lan;
        in {
          ips = ["${vpnNet.base4}${secrets.vpn.reservations.macbook-nixos.address}/${vpnNet.prefix-length4}" "${vpnNet.base6}${secrets.vpn.reservations.macbook-nixos.address}/${vpnNet.prefix-length6}"];
          listenPort = vpnNet.port;
          privateKeyFile = "/home/andreweggleston/.wireguard-keys/private";

          peers = [
            {
              publicKey = vpnNet.public-key;
              allowedIPs = [
                "${vpnNet.base4}0/${vpnNet.prefix-length4}" # vpn network
                "${vpnNet.base6}0/${vpnNet.prefix-length6}" # vpn network
                "${lanNet.base4}0/${lanNet.prefix-length4}" # home network
                "${lanNet.base6}0/${lanNet.prefix-length6}" # home network
              ];
              endpoint = "never.legalizenuclearbombs.com:${builtins.toString vpnNet.port}";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
  programs.nm-applet.enable = true;

  system.stateVersion = "23.11";
}
