# My nix configurations

This repo has my personal configuration for [NixOS](https://nixos.org) with a [home-manager](https://nix-community.github.io/home-manager/) configuration.

Pretty much copied from [yusefnapora's config](https://github.com/yusefnapora/nix-config).

## Structure

- `flake.nix`: flake entrypoint
- `home-manager`: home-manager configurations & features
- `modules`: nixos and home-manager modules that could potentially be upstreamed
- `nixos`: NixOS host configurations & features
- `overlays`: nixpkgs overlays, including local packages & nixpkgs-unstable
- `pkgs`: local packages that could potentially be upstreamed to nixpkgs

## Usage

The `justfile` defines a few recipies using the [just](https://github.com/casey/just) command runner. Run `just --list` to list all recipies. The most important are `just switch`, which builds the config (for the current hostname by default) and switches to it, `just build` which builds but doesn't switch, and `just trace`, which prints the stacktrace when things fail to build.

If you don't have `just` installed but do have nix, run `nix develop` to open a bootstrap shell environment.

## TODOS
### Router:
* Urgent: on reboot, nftables fails to come up because it depends on the wireguard interface existing. 2 options for solutions:
    * Have the nftables systemd unit depend on wireguard--untested and how will wireguard behave? Probably won't go with this one.
    * Have the wireguard systemd unit automatically add/remove nftables rules on start/stop (this is how wireguard usually works with iptables). networking.wireguard.interfaces.<name>.{preSetup, postSetup, postShutdown} are list of commands concatenated by `\n`--which means I can add/remove the vpn-specific nftables rules using the `nft` command. Here's what I would have to do:
        * Have the wireguard service create its own ingress chain instead of referencing the wireguard interface in the original ingress chain.
        * add a rule to ingress_wan chain to accept incoming connections on the vpn port (will need to figure out handles because this accept port should take precedence over the final drop rule)
        * append a rule to inbound_wan `udp dport ${addresses.vpn.port} accept`
        * append a rule to inbound chain `iifname ${interfaces.vpn.name} jump inbound_vpn`
        * append a rule to the forward chain `iifname ${interfaces.vpn.name} oifname { ${interfaces.lan.name}, lo } accept`
* DHCP/DNS High-Availability 
* switch proxmox host to dhcp
* fix http over vpn?? -- only doesnt work for RAX80 access point...
* investigate ipv6 more--test-ipv6.com still fails
* Set up different vlans for regular clients and services -- keep mastodon traffic from clients
    * home switch supports 802.1q vlans, as does proxmox host
* 803.1ad/802.1ax Link Aggregation -- I can "trunk" up to 4 ports on my switch -- should make a "router-bonding" branch 
* ~~Add wireguard vpn server (will require nftables configuration)~~
* ~~Switch from dnsmasq to BIND~~
* ~~Swap DHCP server from dnsmasq to Kea~~
    * ~~local DNS is broken because dnsmasq doesn't know about dhcp leases anymore--Will require configuring kea-ddns-server~~


### lepotato:
* set up remote builds (on nix-devbox)
* DHCP/DNS High-Availability 
