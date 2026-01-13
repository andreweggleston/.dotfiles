{
  inputs,
  outputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../global
    ../features/desktop/common
    ../features/desktop/common/discord.nix
    ../features/desktop/music-production.nix
    ../features/desktop/obs.nix
  ];

  home.packages = [
    pkgs.remmina
    pkgs.parsec-bin
    pkgs.prismlauncher
    pkgs.temurin-bin
  ];
}
