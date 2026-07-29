{
  pkgs,
  secrets,
  ...
}:
let
  # runner and job containers use this to talk to forgejo
  forgejoUrl = "https://forgejo.internal.${secrets.external_domain}";
in
{
  # make sure docker is enabled on host
  virtualisation.docker.enable = true;

  services.gitea-actions-runner = {
    # use the forgejo runner instead of gitea defaul
    package = pkgs.forgejo-runner;

    instances.nascar = {
      enable = true;
      name = "nascar";
      url = forgejoUrl;

      # should contain "TOKEN=<registration token>"
      tokenFile = "/nascar/forgejo-runner.env";

      # `runs-on: <label>` -> docker image the job runs in.
      labels = [
        "docker:docker://node:20-bookworm"
        "ubuntu-latest:docker://node:20-bookworm"
      ];

      # allowed docker volumes that ci jobs can mount
      settings.container.valid_volumes = [
        "forgejo-ci-nix-*"
      ];
    };
  };

  # run gc in the volumes weekly
  systemd.services.forgejo-ci-nix-gc = {
    description = "GC the Forgejo CI /nix cache volumes";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.docker ];
    script = ''
      for vol in forgejo-ci-nix-ordersender forgejo-ci-nix-marketsim; do
        docker volume inspect "$vol" >/dev/null 2>&1 || continue
        docker run --rm -v "$vol":/nix nixos/nix:latest \
          nix-collect-garbage --delete-older-than 30d || true
      done
    '';
  };
  systemd.timers.forgejo-ci-nix-gc = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
