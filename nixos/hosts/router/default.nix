{
  lib,
  pkgs,
  secrets,
  ...
}:
let
  inherit (lib.attrsets) mapAttrsToList;
  lan4 = secrets.hosts.router.networks.lan.base4;
  lan6 = secrets.hosts.router.networks.lan.base6;
  vpn4 = secrets.hosts.router.networks.vpn.base4;
  vpn6 = secrets.hosts.router.networks.vpn.base6;
  dmz4 = secrets.hosts.router.networks.dmz.base4;
  vpnPort = secrets.hosts.router.networks.vpn.port;
  addresses = {
    dmz = {
      ipv4 = {
        base = dmz4;
        addr = "${dmz4}.1";
        subnet = "${dmz4}.0/24";
        dhcpRange = {
          low = "${dmz4}.50";
          high = "${dmz4}.254";
        };
      };
    };
    vpn = {
      ipv4 = {
        base = vpn4;
        addr = "${vpn4}.1";
        subnet = "${vpn4}.0/24";
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
        addr = "${lan4}.1";
        subnet = "${lan4}.0/24";
        dhcpRange = {
          low = "${lan4}.50";
          high = "${lan4}.254";
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
    clients = map (
      {
        name,
        hw_addr,
        addr,
      }:
      {
        inherit name;
        inherit hw_addr;
        addr4 = "${lan4}.${addr}";
        addr6 = "${lan6}${addr}";
      }
    ) secrets.hosts.router.dhcp_reservations;
    vpn-clients = mapAttrsToList (name: value: {
      inherit name;
      publicKey = value.public-key;
      allowedIPs = [
        "${addresses.vpn.ipv4.base}.${value.address}/32"
        "${addresses.vpn.ipv6.base}${value.address}/128"
      ];
    }) secrets.vpn.reservations;
  };
  interfaces = {
    renames = secrets.hosts.router.interfaces;
    lan = {
      name = "bond0.1";
    };
    dmz = {
      name = "bond0.2";
    };
    bond = {
      name = "bond0";
    };
    wan = {
      name = "wan0";
    };
    vpn = {
      name = "wg0";
    };
  };
in
{
  nixpkgs = {
    overlays = [
      (final: prev: {
        ulogd = prev.ulogd.overrideAttrs (oldAttrs: {
          src = fetchGit { url = "https://git.netfilter.org/ulogd2"; };
        });
      })
    ];
  };
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./interfaces.nix {
      inherit addresses;
      inherit interfaces;
      inherit lib;
    })
    (import ./dhcp-dns {
      inherit addresses;
      inherit interfaces;
      inherit lib;
      inherit pkgs;
      inherit secrets;
    })
    (import ./routing.nix {
      inherit addresses;
      inherit interfaces;
    })
    (import ./wireguard.nix {
      inherit addresses;
      inherit interfaces;
      inherit lib;
      inherit pkgs;
      inherit secrets;
    })
    ../../minimal.nix
  ];

  home-manager.users.andreweggleston = import ../../../home-manager/andreweggleston/hosts/router.nix;

  environment.systemPackages = [
    pkgs.dig.out # for tsig-keygen
    pkgs.ulogd
  ];

  services.ulogd = {
    enable = false;
    logLevel = 1;
    settings = {
      pgsql1 = {
        inherit (secrets.hosts.router.ulogd.db) db;
        inherit (secrets.hosts.router.ulogd.db) host;
        inherit (secrets.hosts.router.ulogd.db) user;
        inherit (secrets.hosts.router.ulogd.db) pass;
        inherit (secrets.hosts.router.ulogd.db) port;
        inherit (secrets.hosts.router.ulogd.db) schema;
        inherit (secrets.hosts.router.ulogd.db) table;
        procedure = "INSERT_PACKET_FULL";
      };
      global = {
        stack = [
          "log1:NFLOG,base1:BASE,ip2str1:IP2STR,ifi1:IFINDEX,mac2str1:HWHDR,pgsql1:PGSQL"
        ];
      };
      log1 = {
        group = 1;
      };
    };
  };

  networking = {
    hostName = "router";
    hosts = {
      "127.0.0.2" = lib.mkForce [ ];
      ${addresses.lan.ipv4.addr} = [
        "router"
        "router.peckave.home.arpa"
      ]; # for some reason /etc/hosts has an entry "127.0.0.2 router" and no that 2 is not a typo
    };
  };

  services.openssh.listenAddresses = [
    {
      inherit (addresses.lan.ipv4) addr;
      port = 22;
    }
  ];

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        system = "x86_64-linux";
        sshUser = "andreweggleston";
        sshKey = "/home/andreweggleston/.ssh/id_ed25519";
        hostName = "kilpisjarvi.peckave.home.arpa";
      }
    ];
    settings.trusted-users = [ "andreweggleston" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "24.05";
}
