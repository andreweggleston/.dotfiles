_: {
  services.samba = {
    enable = true;
    securityType = "user";
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nascar";
        "netbios name" = "nascar";
        "security" = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        "path" = "/nascar/backup/";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "andreweggleston";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
  };
}
