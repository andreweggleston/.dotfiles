{ ... }:
{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "andreweggleston" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
