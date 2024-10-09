{
  inputs,
  outputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../global
    ../features/desktop/common
    ../features/desktop/common/discord.nix
    ../features/desktop/bitwig.nix
  ];
}
