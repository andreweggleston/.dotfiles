{
  addresses,
  interfaces,
  secrets,
  lib,
  ...
}: {
  networking.wireguard.interfaces = {
    "${interfaces.vpn.name}" = {
      ips = ["${addresses.vpn.ipv4.addr}/24" "${addresses.vpn.ipv6.addr}/64"];
      listenPort = addresses.vpn.port;
      privateKeyFile = "/home/andreweggleston/.wireguard-keys/private";

      peers =
        lib.attrsets.mapAttrsToList (name: value: {
          inherit name;
          publicKey = value.public-key;
          allowedIPs = ["${addresses.vpn.ipv4.base}${value.address}/32" "${addresses.vpn.ipv6.base}${value.address}/128"];
        })
        secrets.vpn.reservations;
    };
  };
}
