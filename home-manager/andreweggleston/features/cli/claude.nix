{
  lib,
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.unstable.claude-code
  ];
}
