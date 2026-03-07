{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = ''
      AddKeysToAgent=yes
    '';

    matchBlocks = {
      # add host configs here like
      # {name} = {
      #   hostname = {hostname};
      #   user = {user};
      # };

      "*" = {

      };

      uml = {
        hostname = "cs.uml.edu";
        user = "aegglest";
      };
      mercury = {
        hostname = "mercury.cs.uml.edu";
        user = "aegglest";
      };
    };
  };
}
