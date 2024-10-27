{
  config,
  pkgs,
  ...
}: {
  users.users.andreweggleston = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "onepassword" "video" "libvirtd" "audio"];
    shell = pkgs.fish;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDL2iuw70Vw9fghAGz6sqsvLMSVpFa8xxy7iIiY99nWZ05NjRQYow8GUNI3zaTBxc+H+sqO1sQBv2nFarXSS5WTDzRlO6Zrd5RrWs9mNCmObillU35eXIhlFNMcuhaZd0YDH2N6KlD9uJJ3jIgmqlRXL+dUtsl/da4eqxWHbiVfaaWAvJ4esPru+2YVIbhrL2pt41HT1mfbWJWwmsD5ew14rjajh7FsHu3l4s87Fa4e2m7BieHSdDVqndvF1tMx4eiB9Ph6qOAUMPM6ZcsMkOKdczxdj9O1PinSjQKO7Vz3ATUi1McRPjWei3Rz3Sru0oiDsZJbfkE8ZFI+0h72S2C8nk8R9r8D8RfYGstoaodOR0mSj9M3/JU7yBEYNgN3QnWqaw3tMOyYCKQqKBdj69wNdE3zimdnC1VrQybOeMU9hCYvY5ZzlnbwIfSV3X0VKm1696MGBt+7cSIgnxWS1kIafo0kn7nM03AK7XV71KG6ZGFyf5X9A4kDA5wehZAOCvk= andreweggleston"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys =
    config.users.users.andreweggleston.openssh.authorizedKeys.keys;

  # allow running nixos-rebuild as root without a password.
  # requires us to explicitly pull in nixos-rebuild from pkgs, so
  # we get the right path in the sudo config
  environment.systemPackages = [pkgs.nixos-rebuild];
  security.sudo.extraRules = [
    {
      users = ["andreweggleston"];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = ["NOPASSWD" "SETENV"];
        }
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD" "SETENV"];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl";
          options = ["NOPASSWD" "SETENV"];
        }
        # reboot and shutdown are symlinks to systemctl,
        # but need to be authorized in addition to the systemctl binary
        # to allow nopasswd sudo
        {
          command = "/run/current-system/sw/bin/shutdown";
          options = ["NOPASSWD" "SETENV"];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
  ];
}
