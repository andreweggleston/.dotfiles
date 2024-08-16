{
  addresses,
  interfaces,
  ...
}: {
  networking = {
    firewall.enable = true;
    nftables = {
      enable = true;
      checkRuleset = false;
      ruleset = ''
        flush ruleset
        define LAN_SPACE = ${addresses.lan.ipv4.subnet}
        define LAN6_SPACE = ${addresses.lan.ipv6.subnet}

        table netdev filter {
          chain ingress {
            type filter hook ingress devices = { ${interfaces.wan.name}, ${interfaces.lan.name} } priority -500;

            # block weird packets
            tcp flags & (fin|syn) == (fin|syn) drop
            tcp flags & (syn|rst) == (syn|rst) drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|syn|rst|psh|ack|urg) drop
            tcp flags & (fin|syn|rst|psh|ack|urg) == 0 drop
            tcp flags syn tcp option maxseg size 0-500 drop

            # drop incoming packets on WAN that are pretending to be the internal address of the router (the lan interface)
            ip saddr ${addresses.lan.ipv4.addr} drop
            ip6 saddr ${addresses.lan.ipv6.addr} drop

            # drop incoming packets on WAN that are pretending to be internal ULA traffic
            ip6 saddr ${addresses.lan.ipv6.subnet} drop

            # drop packets if the source address is unroutable ("how did you get here?")
            fib saddr . iif oif missing drop
          }
          chain ingress_wan {
            type filter hook ingress device ${interfaces.wan.name} priority -500;
            ip protocol icmp limit rate 5/second accept
            ip protocol icmp counter drop
            # always allow router advertisement (type 134 AKA nd-router-advert)
            ip6 nexthdr icmpv6 icmpv6 type nd-router-advert accept
            ip6 nexthdr icmpv6 limit rate 5/second accept
            ip6 nexthdr icmpv6 counter drop

            # drop incoming packets that are not locally addressed
            fib daddr . iif type != local drop
          }
        }

        table inet global {
          chain inbound_wan {
            # accept all icmp requests -- TODO this could be constrained or even rate-limited
            ip protocol icmp accept
            ip6 nexthdr icmpv6 accept
          }
          chain inbound_lan {
            # accept all LAN traffic--yolo!
            accept
          }
          chain inbound {
            # always allow DHCPv6 on link local -- so the ISP can assign our router an ipv6 address
            udp sport 547 ip6 saddr fe80::/10 accept
            udp dport 546 ip6 daddr fe80::/10 accept
            type filter hook input priority 0; policy drop;

            # drop incoming packets that are new but don't have SYN
            tcp flags & syn != syn ct state new drop

            ct state vmap { established : accept, related : accept, invalid: drop }

            iifname vmap { lo : accept, ${interfaces.wan.name} : jump inbound_wan, ${interfaces.lan.name} : jump inbound_lan }
          }
          chain forward {
            type filter hook forward priority 0; policy drop;

            # always allow ULA traffic within LAN
            ip6 saddr ${addresses.lan.ipv6.subnet} ip6 daddr ${addresses.lan.ipv6.subnet} iifname ${interfaces.lan.name} oifname ${interfaces.lan.name} accept

            # always prevent ULA traffic from being forwarded to WAN
            ip6 saddr ${addresses.lan.ipv6.subnet} oifname ${interfaces.wan.name} drop

            ct state vmap { established : accept, related : accept, invalid : drop }

            iifname ${interfaces.lan.name} accept
          }
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            # do nat for ipv4 clients
            ip saddr ${addresses.lan.ipv4.subnet} oifname ${interfaces.wan.name} masquerade
          }
        }
      '';
    };
  };
}
