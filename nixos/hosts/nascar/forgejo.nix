{
  config,
  lib,
  secrets,
  ...
}:
let
  # reverse proxy on the router
  domain = "forgejo.internal.${secrets.external_domain}";

  # git-over-ssh not forwarded by reverse proxy on the router
  sshDomain = "nascar.${secrets.internal_domain}";
in
{
  # cli tool
  environment.systemPackages = [ config.services.forgejo.package ];

  services.forgejo = {
    enable = true;

    # storage on the zfs tank pool, this also is the homedir of the run user
    stateDir = "/nascar/forgejo";

    database.type = "sqlite3";
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
        HTTP_ADDR = "0.0.0.0"; # reachable from the router for reverse proxying
        HTTP_PORT = 3000;

        # dont start the ssh server because we will just reuse the one on this machine already
        START_SSH_SERVER = false;
        SSH_DOMAIN = sshDomain;
        SSH_PORT = 22;
        SSH_USER = "forgejo"; # == RUN_USER; clone URLs are forgejo@${sshDomain}:owner/repo.git
      };

      service = {
        # no registration, create users with `forgejo admin user create`
        DISABLE_REGISTRATION = true;
      };

      repository = {
        DEFAULT_PRIVATE = "private";
      };

      session = {
        COOKIE_SECURE = true; # HTTPS only thru the reverse proxy
      };

      # Required for any Actions runner to register/pick up jobs. The runner
      # itself (docker executor) lives in ./forgejo-runner.nix.
      actions = {
        ENABLED = true;
        # Fall back to github.com for `uses:` steps not hosted on this instance
        # (e.g. actions/checkout). Workflows can still reference full URLs.
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };
}
