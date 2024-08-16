{
  pkgs,
  secrets,
  ...
}: let
  baseaddr4 = "192.168.3.";
  baseaddr6 = "fdd5:beef:c0de::";
  makeDhcpStaticClient = _name: _address: {
    name = _name;
    addr4 = baseaddr4 + _address;
    addr6 = baseaddr6 + _address;
  };
  addresses = {
    lan = {
      ipv4 = {
        addr = "${baseaddr4}1";
        subnet = "${baseaddr4}0/24";
        dhcpRange = "${baseaddr4}50,${baseaddr4}254,12h";
      };
      ipv6 = {
        addr = "${baseaddr6}1";
        subnet = "${baseaddr6}/64";
        dhcpRange = "${baseaddr6}1000,${baseaddr6}ff00,ra-names,slaac,12h";
      };
    };
    clients = [
      (makeDhcpStaticClient
        "officerouter"
        "2")
      (makeDhcpStaticClient
        "rax80"
        "3")
      (makeDhcpStaticClient
        "kilpisjarvi"
        "4")
      (makeDhcpStaticClient
        "lepotato"
        "49")
    ];
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
    (import ./routing.nix {
      inherit addresses;
      inherit interfaces;
    })
    ../../minimal.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/router.nix;

  environment.systemPackages = [
    pkgs.dig
    pkgs.git-crypt
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
