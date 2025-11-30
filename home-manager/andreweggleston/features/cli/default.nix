{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./fish.nix
    ./nushell
    ./git.nix
    ./helix.nix
    ./npm.nix
    ./ssh.nix
    ./tmux.nix
    ./neovim.nix
  ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      jq
      tealdeer
      unzip
      btop
      htop
      killall
      tree
      lnav
      duf
      ripgrep
      fd
      atool
      bat
      gron
      xh
      just
      vim
      nix-tree
      git-crypt
      wireguard-tools
      dig
      ;
  };

  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  nixpkgs.config = import ./nixpkgs-config.nix;
  home.file."nixpkgs-config" = {
    target = ".config/nixpkgs/config.nix";
    source = ./nixpkgs-config.nix;
  };
}
