{ pkgs, ... }:
{
  home.packages = [
    pkgs.local-pkgs.bitwig-studio6
    pkgs.renoise
    pkgs.audacity
  ];

  home.file.".BitwigStudio/graphics-backend".text = "skia-gl";
}
