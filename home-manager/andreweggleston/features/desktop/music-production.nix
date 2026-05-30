{ pkgs, ... }:
{
  home.packages = [
    pkgs.renoise
    pkgs.audacity
    pkgs.bitwig-studio
  ];

  home.file.".BitwigStudio/graphics-backend".text = "skia-gl";
}
