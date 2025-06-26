{
  addresses,
  interfaces,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) subnet4ToReverseDomain;
  inherit (utils) subnet6ToReverseDomain;
  dmz-zoneFile = pkgs.writeText "peckdmz.home.arpa.zone" ''
    $TTL 2d
    @       IN    SOA     router.peckdmz.home.arpa. admin.peckdmz.home.arpa (
                          2024082501  ; Serial
                          3600        ; Refresh
                          1800        ; Retry
                          1209600     ; Expire
                          172800      ; Minimum TTL
                          )

            IN    NS      router.peckdmz.home.arpa.

    router  IN    A       ${addresses.dmz.ipv4.addr}
  '';
  home-zoneFile = pkgs.writeText "peckave.home.arpa.zone" ''
    $TTL 2d
    @       IN    SOA     router.peckave.home.arpa. admin.peckave.home.arpa (
                          2024082501  ; Serial
                          3600        ; Refresh
                          1800        ; Retry
                          1209600     ; Expire
                          172800      ; Minimum TTL
                          )

            IN    NS      router.peckave.home.arpa.

    router  IN    A       ${addresses.lan.ipv4.addr}
    router  IN    AAAA    ${addresses.lan.ipv6.addr}
  '';
  root-hintFile = pkgs.writeText "root.hints" ''
    .                        3600000      NS    A.ROOT-SERVERS.NET.
    A.ROOT-SERVERS.NET.      3600000      A     198.41.0.4
    A.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:ba3e::2:30
    .                        3600000      NS    B.ROOT-SERVERS.NET.
    B.ROOT-SERVERS.NET.      3600000      A     170.247.170.2
    B.ROOT-SERVERS.NET.      3600000      AAAA  2801:1b8:10::b
    .                        3600000      NS    C.ROOT-SERVERS.NET.
    C.ROOT-SERVERS.NET.      3600000      A     192.33.4.12
    C.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:2::c
    .                        3600000      NS    D.ROOT-SERVERS.NET.
    D.ROOT-SERVERS.NET.      3600000      A     199.7.91.13
    D.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:2d::d
    .                        3600000      NS    E.ROOT-SERVERS.NET.
    E.ROOT-SERVERS.NET.      3600000      A     192.203.230.10
    E.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:a8::e
    .                        3600000      NS    F.ROOT-SERVERS.NET.
    F.ROOT-SERVERS.NET.      3600000      A     192.5.5.241
    F.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:2f::f
    .                        3600000      NS    G.ROOT-SERVERS.NET.
    G.ROOT-SERVERS.NET.      3600000      A     192.112.36.4
    G.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:12::d0d
    .                        3600000      NS    H.ROOT-SERVERS.NET.
    H.ROOT-SERVERS.NET.      3600000      A     198.97.190.53
    H.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:1::53
    .                        3600000      NS    I.ROOT-SERVERS.NET.
    I.ROOT-SERVERS.NET.      3600000      A     192.36.148.17
    I.ROOT-SERVERS.NET.      3600000      AAAA  2001:7fe::53
    .                        3600000      NS    J.ROOT-SERVERS.NET.
    J.ROOT-SERVERS.NET.      3600000      A     192.58.128.30
    J.ROOT-SERVERS.NET.      3600000      AAAA  2001:503:c27::2:30
    .                        3600000      NS    K.ROOT-SERVERS.NET.
    K.ROOT-SERVERS.NET.      3600000      A     193.0.14.129
    K.ROOT-SERVERS.NET.      3600000      AAAA  2001:7fd::1
    .                        3600000      NS    L.ROOT-SERVERS.NET.
    L.ROOT-SERVERS.NET.      3600000      A     199.7.83.42
    L.ROOT-SERVERS.NET.      3600000      AAAA  2001:500:9f::42
    .                        3600000      NS    M.ROOT-SERVERS.NET.
    M.ROOT-SERVERS.NET.      3600000      A     202.12.27.33
    M.ROOT-SERVERS.NET.      3600000      AAAA  2001:dc3::35
  '';
  bind-configFile = pkgs.writeText "named.conf" ''
    acl homenets {
      127.0.0.0/24;
      ::1/128;

      ${addresses.lan.ipv4.subnet};
      ${addresses.vpn.ipv4.subnet};
      ${addresses.dmz.ipv4.subnet};

      ${addresses.lan.ipv6.subnet};
      ${addresses.vpn.ipv6.subnet};
    };

    # keys
    ${lib.strings.concatStringsSep "\n" (
      map (
        {
          name,
          algorithm,
          secret,
        }:
        ''key ${name} { algorithm ${algorithm}; secret ${secret}; }; ''
      ) secrets.hosts.router.dhcp-ddns-keys
    )}

    options {
      directory "/run/named";
      allow-query { homenets; };
      recursion yes;
      listen-on { 127.0.0.0/8; ${addresses.lan.ipv4.subnet}; ${addresses.vpn.ipv4.subnet}; ${addresses.dmz.ipv4.subnet}; };
    };

    zone "peckave.home.arpa" IN {
      type master;
      file "/var/named/zones/peckave.home.arpa.zone";
      allow-update { key "router-ddns"; };
    };

    zone "peckdmz.home.arpa" IN {
      type master;
      file "/var/named/zones/peckdmz.home.arpa.zone";
      allow-update { key "router-ddns"; };
    };

    zone "." IN {
      type hint;
      file "${root-hintFile}";
    };
  '';
in
{
  services = {
    bind = {
      enable = true;
      configFile = bind-configFile;
      ipv4Only = true;
    };
  };

  systemd.services.bind.serviceConfig = {
    ReadWritePaths = [ "/var/named" ];
  };

  system.activationScripts.copyZoneFile = {
    text = ''
      mkdir -p /var/named/zones
      cp ${home-zoneFile} /var/named/zones/peckave.home.arpa.zone
      cp ${dmz-zoneFile} /var/named/zones/peckdmz.home.arpa.zone
      chown named:named -R /var/named/zones
      chmod 0644 /var/named/zones/peckave.home.arpa.zone
      chmod 0644 /var/named/zones/peckdmz.home.arpa.zone
    '';
  };
}
