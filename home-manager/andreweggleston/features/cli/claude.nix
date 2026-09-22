{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
  ];

  home.packages = [
    pkgs.claude-code
  ];
}
