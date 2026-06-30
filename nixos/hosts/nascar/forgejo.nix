{
  config,
  lib,
  secrets,
  ...
}:
let
  # Reverse proxy + TLS for this name are provided centrally by Caddy on the
  # router (see nixos/hosts/router/{default,reverse-proxy}.nix). Adding the
  # matching entry to the router's `services` list publishes:
  #   forgejo.peckave.home.arpa       (internal CA)
  #   forgejo.internal.lmao.blog      (real cert via porkbun DNS-01)
  domain = "forgejo.internal.${secrets.external_domain}";
in
{
  # Put the matching forgejo CLI on PATH for admin tasks. It still needs the
  # service's work dir/config to avoid defaulting WORK_PATH into the read-only
  # nix store, e.g.:
  #   sudo -u forgejo env GITEA_WORK_DIR=/nascar/forgejo forgejo admin user create ...
  environment.systemPackages = [ config.services.forgejo.package ];

  services.forgejo = {
    enable = true;

    # Bulk storage on the tank pool rather than rpool/root. The module also
    # makes this the run user's home, so host-sshd git access reads
    # ${stateDir}/.ssh/authorized_keys.
    stateDir = "/nascar/forgejo";

    database.type = "sqlite3";
    lfs.enable = true;

    # SECRET_KEY / INTERNAL_TOKEN / JWT secrets are generated and persisted by
    # the module under stateDir automatically; nothing to add to secrets.json.

    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_ADDR = "0.0.0.0"; # reachable from the router for reverse proxying
        HTTP_PORT = 3000;

        # git over SSH via the host's existing sshd on port 22 (no built-in
        # server). Forgejo writes forced-command entries into the run user's
        # authorized_keys, so connecting as forgejo@ is routed into `forgejo serv`.
        START_SSH_SERVER = false;
        SSH_DOMAIN = domain;
        SSH_PORT = 22;
        SSH_USER = "forgejo"; # == RUN_USER; clone URLs are forgejo@${domain}:owner/repo.git
      };

      service = {
        # Private homelab instance: no open self-registration. Create the first
        # admin with `forgejo admin user create` (see notes below).
        DISABLE_REGISTRATION = true;
      };

      repository = {
        DEFAULT_PRIVATE = "private";
      };

      session = {
        COOKIE_SECURE = true; # served only over HTTPS via Caddy
      };
    };
  };
}
