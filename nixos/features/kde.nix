{
  pkgs,
  lib,
  ...
}: {
  services = {
    xserver.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
  };

  programs.dconf.enable = true;
}
