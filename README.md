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
