{pkgs, ...}: {
  services.sunshine = {
    enable = true;
    package = pkgs.sunshine.override {cudaSupport = true;};
    capSysAdmin = true;
    openFirewall = true;
  };
}
