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
    };
  };
}
