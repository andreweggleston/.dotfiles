{ pkgs, ... }:
{
  home.packages = [
    pkgs.bitwig-studio5
    pkgs.renoise
    pkgs.audacity
  ];

  home.file.".BitwigStudio/graphics-backend".text = "skia-gl";
}
