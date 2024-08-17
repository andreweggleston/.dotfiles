{interfaces, ...}: {
  services = {
    dnsmasq = {
      enable = true;
      settings = {
        except-interface = interfaces.wan.name;
        domain = "peckave.local";
        local = "/peckave.local/";
        expand-hosts = true;
      };
    };
  };
}
