{
  pkgs,
  lib,
  ...
}:
{
  services = {
    xserver.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
  };

  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
    wlr = {
      enable = true;
    };
  };
}
