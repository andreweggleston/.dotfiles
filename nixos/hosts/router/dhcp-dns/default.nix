{
  addresses,
  interfaces,
  lib,
  pkgs,
  secrets,
  ...
}: {
  imports = [
    (import ./dhcp.nix {
      inherit addresses;
      inherit interfaces;
      inherit secrets;
    })
    (import ./ddns.nix {
      inherit addresses;
      inherit interfaces;
      inherit lib;
      inherit secrets;
    })
    (import ./dns.nix {
      inherit addresses;
      inherit interfaces;
      inherit lib;
      inherit pkgs;
      inherit secrets;
    })
  ];
}
