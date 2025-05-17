{
  addresses,
  interfaces,
  lib,
  ...
}:
let
  mkUdevInterfaceNameRule =
    {
      name,
      mac,
    }:
    ''SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${mac}", NAME="${name}"'';
in
{
  # name interfaces
  services.udev.extraRules = lib.concatStringsSep "\n" (
    map mkUdevInterfaceNameRule interfaces.renames
  );
  networking = {
    interfaces = {
      # get address from isp
      "${interfaces.wan.name}" = {
        useDHCP = true;
      };
      # lan address space
      "${interfaces.lan.name}" = {
        ipv4.addresses = [
          {
            address = addresses.lan.ipv4.addr;
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = addresses.lan.ipv6.addr;
            prefixLength = 64;
          }
        ];
      };
    };
    dhcpcd = {
      allowInterfaces = [ interfaces.wan.name ];
      extraConfig = ''
        persistent
        nohook resolv.conf
        duid
        slaac private
        interface ${interfaces.wan.name}
          iaid 0
          ipv4
          ipv6
          ipv6rs
          ia_na 0
          ia_pd 0/::/60 ${interfaces.lan.name}/5/64
      '';
    };
  };
}
