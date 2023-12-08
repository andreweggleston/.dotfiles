{ pkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  imports = [
    ./common.nix
    ../features/yabai.nix
    ../features/yabai-scripting-additions.nix
  ];

  home-manager.users.andreweggleston = import ../../home-manager/andreweggleston/hosts/macbook-darwin.nix;

  # TODO: system.stateVersion = 4;
}
