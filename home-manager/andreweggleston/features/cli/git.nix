{
  config,
  pkgs,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Andrew Eggleston";
        email = "egglestonandrew927@gmail.com";
      };
      alias = {
        upstream-name = "!git remote | egrep -o '(upstream|origin)' | tail -1";
        head-branch = "!basename $(git symbolic-ref refs/remotes/$(git upstream-name)/HEAD)";
        cm = "!git checkout $(git head-branch)";
        co = "checkout";
        cob = "checkout -b";
        repo-root = "rev-parse --show-toplevel";
        rr = "rev-parse --show-toplevel";
      };
      init.defaultBranch = "main";
    };
    includes = [
      {
        path = "~/.config/git/config-sharefile.inc";
        condition = "gitdir:~/work";
      }
    ];

    ignores = [
      ".env"
      ".envrc"
      ".direnv/"
      "*.swp"
      ".idea/"
    ];
  };
}
