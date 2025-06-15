{ pkgs, ... }:
{
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.writers.writeDash "netns-up" ''
        ${pkgs.iproute2}/bin/ip netns add $1
        ${pkgs.utillinux}/bin/umount /var/run/netns/$1
        ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
      ''} %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      PrivateMounts = false; # https://github.com/systemd/systemd/issues/28686
    };
  };

  systemd.services.vpn_wg = {
    description = "wireguard vpn network interface";
    bindsTo = [ "netns@vpn_wg.service" ];
    requires = [
      "network-online.target"
      "nss-lookup.target"
    ];
    after = [
      "netns@vpn_wg.service"
      "network-online.target"
      "nss-lookup.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart =
        with pkgs;
        writers.writeBash "vpn_wg-up" ''
          ${iproute2}/bin/ip link add wg0 type wireguard
          ${wireguard-tools}/bin/wg setconf wg0 /root/vpn-wg.conf
          ${iproute2}/bin/ip link set mtu 1320 dev wg0
          ${iproute2}/bin/ip link set wg0 netns vpn_wg up
          ${iproute2}/bin/ip -n vpn_wg address add 10.168.252.39/32 dev wg0
          # need to set lo up as network namespace is started with lo down
          ${iproute2}/bin/ip -n vpn_wg link set lo up
          ${iproute2}/bin/ip -n vpn_wg route add default dev wg0
        '';
      ExecStop =
        with pkgs;
        writers.writeBash "vpn_wg-down" ''
          ${iproute2}/bin/ip -n vpn_wg route del default dev wg0
          ${iproute2}/bin/ip -n vpn_wg link del wg0
        '';
    };
  };
}
