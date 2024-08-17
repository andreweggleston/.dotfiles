{
  addresses,
  interfaces,
  ...
}: {
  services = {
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [interfaces.lan.name];
          };
          lease-database = {
            name = "/var/lib/kea/dhcp4.leases";
            persist = true;
            type = "memfile";
          };
          valid-lifetime = 28800;
          option-data = [
            {
              name = "domain-name-servers";
              data = addresses.lan.ipv4.addr;
            }
          ];
          subnet4 = [
            {
              subnet = addresses.lan.ipv4.subnet;
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
              ];
              reservations =
                map ({
                  name,
                  hw_addr,
                  addr4,
                  addr6,
                }: {
                  hostname = name;
                  hw-address = hw_addr;
                  ip-address = addr4;
                })
                addresses.clients;
            }
          ];
        };
      };
      dhcp6 = {
        enable = true;
        settings = {
          interfaces-config = {
            interfaces = [interfaces.lan.name];
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
          subnet6 = [
            {
              subnet = addresses.lan.ipv6.subnet;
              pools = [
                {
                  pool = "${addresses.lan.ipv6.dhcpRange.low} - ${addresses.lan.ipv6.dhcpRange.high}";
                }
              ];
              reservations =
                map ({
                  name,
                  hw_addr,
                  addr4,
                  addr6,
                }: {
                  hostname = name;
                  hw-address = hw_addr;
                  ip-addresses = [addr6];
                })
                addresses.clients;
            }
          ];
        };
      };
    };
  };
}
