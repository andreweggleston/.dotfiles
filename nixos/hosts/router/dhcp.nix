{
  addresses,
  interfaces,
  ...
}: {
  services = {
    dnsmasq = {
      enable = true;
      settings = {
        except-interface = interfaces.wan.name;
        interface = interfaces.lan.name;
        domain = "peckave.local";
        local = "/peckave.local/";
        expand-hosts = true;
        enable-ra = true;
        dhcp-authoritative = true;
        dhcp-range = [
          addresses.lan.ipv4.dhcpRange
          addresses.lan.ipv6.dhcpRange
        ];
        dhcp-host = map ({
          name,
          addr4,
          addr6,
        }: "${name},${addr4},[${addr6}],12h")
        addresses.clients;
      };
    };
  };
}
