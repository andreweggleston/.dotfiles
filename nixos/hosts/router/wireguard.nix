{
  config,
  addresses,
  interfaces,
  ...
}: {
  networking.wireguard.interfaces = {
    "${interfaces.vpn.name}" = {
      ips = ["${addresses.vpn.ipv4.addr}/24" "${addresses.vpn.ipv6.addr}/64"];
      listenPort = addresses.vpn.port;
      privateKeyFile = "/home/andreweggleston/.wireguard-keys/private";

      peers = [
        {
          name = "m2-darwin";
          publicKey = "In2G6D2xo6yU+0j5Q8rSKGGQaeu6CIKPRbg+4qhvjw0=";
          allowedIPs = ["${addresses.vpn.ipv4.base}2/32" "${addresses.vpn.ipv6.base}2/128"];
        }
      ];
    };
  };
}
