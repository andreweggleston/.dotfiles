{ pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    package = pkgs.unstable.sunshine.override { cudaSupport = true; };
    capSysAdmin = true;
    openFirewall = true;
  };
}
