{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.bitwig-studio5
    pkgs.renoise
  ];
}
