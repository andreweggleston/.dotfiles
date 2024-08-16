{
  addresses,
  interfaces,
  ...
}: {
  # name interfaces
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${interfaces.lan.mac}", NAME="${interfaces.lan.name}"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${interfaces.wan.mac}", NAME="${interfaces.wan.name}"

  '';
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
      allowInterfaces = [interfaces.wan.name];
      extraConfig = ''
        denyinterfaces ${interfaces.lan.name}
        persistent
        nohook resolv.conf
        duid
        slaac private
        interface ${interfaces.wan.name}
          ipv4
          ipv6
          ipv6rs
          ia_na 0
          ia_pd 0/::/60 ${interfaces.lan.name}/5/64
      '';
    };
  };
}
