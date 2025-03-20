{
  addresses,
  interfaces,
  secrets,
  lib,
  pkgs,
  ...
}:
let
  nft = pkgs.nftables;
in
{
  networking.wireguard.interfaces = {
    "${interfaces.vpn.name}" = {
      postSetup = ''
        # modify ingress chain filter to include wg0 device
        ${nft}/bin/nft chain netdev filter ingress '{ type filter hook ingress devices = { ${interfaces.wan.name}, ${interfaces.lan.name}, ${interfaces.vpn.name} } priority -500; policy accept; }'

        # insert accept dport rule 2nd to last in ingress_wan chain in filter table
          # use handles as in `nft --handle list ruleset`
        ${nft}/bin/nft add rule netdev filter ingress_wan handle 16 udp dport ${builtins.toString addresses.vpn.port} accept

        # append accept dport rule to inbound_wan chain in global table
        ${nft}/bin/nft add rule inet global inbound_wan udp dport ${builtins.toString addresses.vpn.port} accept

        # append jump accept iifname vpn to inbound chain in global table
        ${nft}/bin/nft add chain inet global inbound_vpn
        ${nft}/bin/nft add rule inet global inbound_vpn accept
        ${nft}/bin/nft add rule inet global inbound iifname ${interfaces.vpn.name} jump inbound_vpn

        # append accept iifname vpn oifname { lan, lo } rule to forward chain in global table
        ${nft}/bin/nft add rule inet global forward iifname ${interfaces.vpn.name} oifname { ${interfaces.lan.name}, lo } accept
      '';
      postShutdown = ''
        # inverse of postSetup -- remove all rules added AND NOTHING MORE
        # could do nothing... or just restart nftables service...?
        systemctl restart nftables
      '';

      ips = [
        "${addresses.vpn.ipv4.addr}/24"
        "${addresses.vpn.ipv6.addr}/64"
      ];
      listenPort = addresses.vpn.port;
      privateKeyFile = "/home/andreweggleston/.wireguard-keys/private";

      peers = lib.attrsets.mapAttrsToList (name: value: {
        inherit name;
        publicKey = value.public-key;
        allowedIPs = [
          "${addresses.vpn.ipv4.base}.${value.address}/32"
          "${addresses.vpn.ipv6.base}${value.address}/128"
        ];
      }) secrets.vpn.reservations;
    };
  };
}
