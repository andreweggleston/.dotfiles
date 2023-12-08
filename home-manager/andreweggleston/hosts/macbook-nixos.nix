{ inputs, outputs, lib, pkgs, config, ... }:
{
  imports = [
    ../global
    ../features/desktop/common
    ../features/desktop/sway 
    ../features/desktop/sway/natural-scrolling.nix
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 2650;
      height = 1440;
      scale = 1.5;
    }
  ];
}
