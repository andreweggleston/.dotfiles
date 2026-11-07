{ pkgs, ... }:
{
  home.packages = [
    pkgs.renoise
    pkgs.audacity
    pkgs.bitwig-studio
    pkgs.mixxx
  ];

  home.file.".BitwigStudio/graphics-backend".text = "skia-gl";
}
