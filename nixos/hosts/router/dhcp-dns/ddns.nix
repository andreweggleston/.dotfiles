{
  addresses,
  interfaces,
  lib,
  secrets,
  ...
}:
let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) subnet4ToReverseDomain;
  inherit (utils) subnet6ToReverseDomain;
in
{
  services = {
    kea.dhcp-ddns = {
      enable = true;
      settings = {
        ip-address = "127.0.0.1"; # lo only
        port = 53001;
        tsig-keys = secrets.hosts.router.dhcp-ddns-keys;
        forward-ddns = {
          ddns-domains = [
            {
              name = "${secrets.internal_domain}.";
              key-name = "router-ddns";
              dns-servers = [
                {
                  ip-address = addresses.lan.ipv4.addr;
                  port = 53;
                }
                {
                  ip-address = addresses.lan.ipv6.addr;
                  port = 53;
                }
              ];
            }
            {
              name = "peckdmz.home.arpa.";
              key-name = "router-ddns";
              dns-servers = [
                {
                  ip-address = addresses.dmz.ipv4.addr;
                  port = 53;
                }
              ];
            }
          ];
        };
        # reverse-ddns = {
        #   ddns-domains = [
        #     {
        #       name = subnet4ToReverseDomain addresses.lan.ipv4.subnet;
        #       key-name = "router-ddns";
        #       dns-servers = [
        #         {
        #           ip-address = addresses.lan.ipv4.addr;
        #           port = 53;
        #         }
        #         {
        #           ip-address = addresses.lan.ipv6.addr;
        #           port = 53;
        #         }
        #       ];
        #     }
        #     {
        #       name = subnet6ToReverseDomain addresses.lan.ipv6.subnet;
        #       key-name = "router-ddns";
        #       dns-servers = [
        #         {
        #           ip-address = addresses.lan.ipv4.addr;
        #           port = 53;
        #         }
        #         {
        #           ip-address = addresses.lan.ipv6.addr;
        #           port = 53;
        #         }
        #       ];
        #     }
        #   ];
        # };
      };
    };
  };
}
