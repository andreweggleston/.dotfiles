{
  pkgs,
  secrets,
  ...
}: let
  lan4 = "192.168.3.";
  lan6 = "fdd5:beef:c0de::";
  vpn4 = "10.177.23.";
  vpn6 = "fddb:05a0:ea9a::";
  vpnPort = 30441;
  makeDhcpReservation = {
    name,
    hw_addr,
    addr,
  }: {
    inherit name;
    inherit hw_addr;
    addr4 = "${lan4}${addr}";
    addr6 = "${lan6}${addr}";
  };
  addresses = {
    vpn = {
      ipv4 = {
        base = vpn4;
        addr = "${vpn4}1";
        subnet = "${vpn4}0/24";
      };
      ipv6 = {
        base = vpn6;
        addr = "${vpn6}1";
        subnet = "${vpn6}/64";
      };
      port = vpnPort;
    };
    lan = {
      ipv4 = {
        addr = "${lan4}1";
        subnet = "${lan4}0/24";
        dhcpRange = {
          low = "${lan4}50";
          high = "${lan4}254";
        };
      };
      ipv6 = {
        addr = "${lan6}1";
        subnet = "${lan6}/64";
        dhcpRange = {
          low = "${lan6}1000";
          high = "${lan6}ff00";
        };
      };
    };
    clients = map makeDhcpReservation secrets.router.dhcp_reservations;
  };
  interfaces = {
    lan = {
      name = "lan0";
      mac = secrets.router.lan_mac;
    };
    wan = {
      name = "wan0";
      mac = secrets.router.wan_mac;
    };
    vpn = {
      name = "wg0";
    };
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./interfaces.nix {
      inherit addresses;
      inherit interfaces;
    })
    (import ./dhcp.nix {
      inherit addresses;
      inherit interfaces;
    })
    (import ./dns.nix {
      inherit interfaces;
    })
    (import ./routing.nix {
      inherit addresses;
      inherit interfaces;
    })
    (import ./wireguard.nix {
      inherit addresses;
      inherit interfaces;
    })
    ../../minimal.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/router.nix;

  environment.systemPackages = [
    pkgs.dig
    pkgs.git-crypt
    pkgs.wireguard-tools
  ];

  networking = {
    hostName = "router";
    hosts = {
      ${addresses.lan.ipv4.addr} = ["router" "router.peckave.local"]; # for some reason /etc/hosts has an entry "127.9.9.2 router" and no that 2 is not a typo
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}
