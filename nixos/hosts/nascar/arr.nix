{ pkgs, ... }:
{
  services.sonarr = {
    enable = true;
  };

  services.radarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
  };
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
      libva-vdpau-driver # Previously vaapiVdpau
      # OpenCL support for intel CPUs before 12th gen
      # see: https://github.com/NixOS/nixpkgs/issues/356535
      intel-compute-runtime-legacy1
      vpl-gpu-rt # QSV on 11th gen or newer
      intel-media-sdk # QSV up to 11th gen
      intel-ocl # OpenCL support
    ];
  };

  environment.systemPackages = [
    pkgs.intel-gpu-tools
  ];

  boot.kernelParams = [
    "i915.enable_guc=2"
    "i915.disable_display=1"
  ];

  services.plex = {
    enable = true;
  };
}
