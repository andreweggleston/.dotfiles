{
  addresses,
  interfaces,
  ...
}:
{
  services = {
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [
              interfaces.lan.name
              interfaces.dmz.name
            ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          valid-lifetime = 28800;
          dhcp-ddns = {
            enable-updates = true;
            server-ip = "127.0.0.1";
            server-port = 53001;
          };
          ddns-send-updates = true;
          subnet4 = [
            {
              id = 1;
              interface = interfaces.lan.name;
              subnet = addresses.lan.ipv4.subnet;
              ddns-qualifying-suffix = "peckave.home.arpa";
              ddns-send-updates = true;
              ddns-override-client-update = true;
              ddns-override-no-update = true;
              ddns-update-on-renew = true;
              pools = [
                {
                  pool = "${addresses.lan.ipv4.dhcpRange.low} - ${addresses.lan.ipv4.dhcpRange.high}";
                }
              ];
              option-data = [
                {
                  name = "routers";
                  data = addresses.lan.ipv4.addr;
                }
                {
                  name = "domain-search";
                  data = "peckave.home.arpa";
                }
                {
                  name = "domain-name-servers";
                  data = addresses.lan.ipv4.addr;
                }
              ];
              reservations = map (
                {
                  name,
                  hw_addr,
                  addr4,
                  addr6,
                }:
                {
                  hostname = name;
                  hw-address = hw_addr;
                  ip-address = addr4;
                }
              ) addresses.clients;
            }

            {
              id = 2;
              interface = interfaces.dmz.name;
              subnet = addresses.dmz.ipv4.subnet;
              ddns-qualifying-suffix = "peckdmz.home.arpa";
              ddns-send-updates = true;
              ddns-override-client-update = true;
              ddns-override-no-update = true;
              ddns-update-on-renew = true;
              pools = [
                {
                  pool = "${addresses.dmz.ipv4.dhcpRange.low} - ${addresses.dmz.ipv4.dhcpRange.high}";
                }
              ];
              option-data = [
                {
                  name = "domain-search";
                  data = "peckdmz.home.arpa";
                }
                {
                  name = "domain-name-servers";
                  data = addresses.dmz.ipv4.addr;
                }
              ];
            }
          ];
        };
      };
      dhcp6 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [ interfaces.lan.name ];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp6.leases";
            persist = true;
            type = "memfile";
          };
          valid-lifetime = 28800;
          option-data = [
            {
              name = "dns-servers";
              data = addresses.lan.ipv6.addr;
            }
          ];
          dhcp-ddns = {
            enable-updates = true;
            server-ip = "127.0.0.1";
            server-port = 53001;
          };
          ddns-send-updates = true;
          subnet6 = [
            {
              id = 1;
              ddns-qualifying-suffix = "peckave.home.arpa";
              ddns-send-updates = true;
              ddns-override-client-update = true;
              ddns-override-no-update = true;
              ddns-update-on-renew = true;
              subnet = addresses.lan.ipv6.subnet;
              pools = [
                {
                  pool = "${addresses.lan.ipv6.dhcpRange.low} - ${addresses.lan.ipv6.dhcpRange.high}";
                }
              ];
              option-data = [
                {
                  name = "domain-search";
                  data = "peckave.home.arpa";
                }
              ];
              reservations = map (
                {
                  name,
                  hw_addr,
                  addr4,
                  addr6,
                }:
                {
                  hostname = name;
                  hw-address = hw_addr;
                  ip-addresses = [ addr6 ];
                }
              ) addresses.clients;
            }
          ];
        };
      };
    };
  };
}
