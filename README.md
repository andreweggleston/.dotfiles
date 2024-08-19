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
* ~~Swap DHCP server from dnsmasq to Kea~~
    * to support dhcp HA
    * local DNS is broken because dnsmasq doesn't know about dhcp leases anymore--Will require configuring kea-ddns-server 
* RE: above; should also switch from dnsmasq to a combination of BIND and unbound (can also do HA on lepotato)
* switch proxmox host to dhcp
* fix http over vpn?? -- only doesnt work for RAX80 access point...
* investigate ipv6 more--test-ipv6.com still fails
* Set up different vlans for regular clients and services -- keep mastodon traffic from clients
    * home switch supports 802.1q vlans, as does proxmox host
* ~~Router: add wireguard vpn server (will require nftables configuration)~~

### lepotato:
* set up remote builds (on nix-devbox)
* add kea dhcp server for HA
