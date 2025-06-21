{
  pkgs,
  lib,
  ...
}:
{
  # set the console font
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = lib.mkDefault "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v16n.psf.gz";
    packages = [ pkgs.powerline-fonts ];
    keyMap = "us";
  };

  # accept the license for the Joypixels font
  nixpkgs.config.joypixels.acceptLicense = true;

  fonts.fontconfig = {
    enable = lib.mkForce true;

    defaultFonts = {
      serif = [
        "Liberation Serif"
        "Joypixels"
      ];
      sansSerif = [
        "Noto Sans"
        "Joypixels"
      ];
      monospace = [ "FiraCode Nerd Font Mono" ];
      emoji = [ "Joypixels" ];
    };

    # fix pixelation
    antialias = true;

    # fix antialiasing blur
    hinting = {
      enable = true;
      style = "full";
      autohint = true;
    };

    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };

  fonts.packages = [
    pkgs.fira-code
    pkgs.noto-fonts
    pkgs.open-fonts
    pkgs.powerline-fonts
    pkgs.liberation_ttf
    pkgs.iosevka
    pkgs.joypixels

    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.droid-sans-mono
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fantasque-sans-mono
  ];

}
