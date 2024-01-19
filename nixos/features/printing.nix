{ ... }:
{
  services.printing.enable = true;

  #autodiscovery of network printers
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };
}
