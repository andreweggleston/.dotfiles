{
  addresses,
  interfaces,
  ...
}:
{
  networking = {
    firewall.enable = true;
    nftables = {
      enable = true;
      checkRuleset = false;
      ruleset = ''
        flush ruleset

        table netdev filter {
          chain ingress {
            type filter hook ingress devices = { ${interfaces.wan.name}, ${interfaces.lan.name} } priority -500;

            # block weird packets
            tcp flags & (fin|syn) == (fin|syn) log prefix "NFT_DROP_WEIRD_FLAGS: " group 1 drop 
            tcp flags & (syn|rst) == (syn|rst) log prefix "NFT_DROP_WEIRD_FLAGS: " group 1 drop 
            tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|syn|rst|psh|ack|urg) log prefix "NFT_DROP_WEIRD_FLAGS: " group 1 drop 
            tcp flags & (fin|syn|rst|psh|ack|urg) == 0 log prefix "NFT_DROP_WEIRD_FLAGS: " group 1 drop 
            tcp flags syn tcp option maxseg size 0-500 log prefix "NFT_DROP_WEIRD_MSS: " group 1 drop 

            # drop incoming packets that are pretending to be the internal address of the router (the lan interface)
            ip saddr ${addresses.lan.ipv4.addr} log prefix "NFT_SPOOF_LAN: " group 1 drop 
            ip6 saddr ${addresses.lan.ipv6.addr} log prefix "NFT_SPOOF_LAN6: " group 1 drop 

            # drop incoming packets on WAN that are pretending to be internal ULA traffic
            ip6 saddr ${addresses.lan.ipv6.subnet} log prefix "NFT_DROP_SPOOF_ULA: " group 1 drop 

            # drop packets if the source address is unroutable ("how did you get here?")
            fib saddr . iif oif missing log prefix "NFT_DROP_UNROUTABLE: " group 1 drop 
          }
          chain ingress_wan {
            type filter hook ingress device ${interfaces.wan.name} priority -500;
            ip protocol icmp limit rate 5/second accept
            ip protocol icmp counter log prefix "NFT_DROP_ICMP: " group 1 drop 
            # always allow router advertisement (type 134 AKA nd-router-advert)
            ip6 nexthdr icmpv6 icmpv6 type nd-router-advert accept
            ip6 nexthdr icmpv6 limit rate 5/second accept
            ip6 nexthdr icmpv6 counter log prefix "NFT_DROP_ICMP6: " group 1 drop 

            # drop incoming packets that are not locally addressed
            fib daddr . iif type != local log prefix "NFT_DROP_UNROUTABLE_WAN: " group 1 drop 
          }
        }

        table inet global {
          chain inbound_wan {
            ct state new log prefix "NFT_INBOUND_NEW_CONN: " group 1 limit rate 5/second
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
            
            # log outbound connections
            ip saddr 192.168.3.0/24 oifname wan0 ct state new log prefix "NFT_FORWARD_NEW_CONN: " group 1 limit rate 5/second

            ct state vmap { established : accept, related : accept, invalid : drop }

            # always forward lan traffic anywhere
            iifname ${interfaces.lan.name} accept
          }
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            # do nat for ipv4 clients
            ip saddr ${addresses.lan.ipv4.subnet} oifname ${interfaces.wan.name} log prefix "NFT_NAT: " group 1 masquerade 
          }
        }
      '';
    };
  };
}
