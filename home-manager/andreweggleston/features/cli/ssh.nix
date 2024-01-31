{ ... }:
{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      AddKeysToAgent=yes
    '';

    matchBlocks = {
      # add host configs here like
      # {name} = {
      #   hostname = {hostname};
      #   user = {user};
      # };

      uml = {
        hostname = "cs.uml.edu";
        user = "aegglest";
      };
    };
  };
}
