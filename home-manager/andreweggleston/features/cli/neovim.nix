{
  lib,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    plugins = [
      pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.unstable.vimPlugins.nvim-treesitter
    ];
    extraPackages = [
      pkgs.unstable.tree-sitter-grammars.tree-sitter-c
      pkgs.unstable.tree-sitter-grammars.tree-sitter-cpp
      pkgs.unstable.tree-sitter-grammars.tree-sitter-cmake
      pkgs.unstable.clang-tools

      pkgs.unstable.tree-sitter
      pkgs.unstable.lua54Packages.jsregexp
      pkgs.unstable.tree-sitter-grammars.tree-sitter-lua
      pkgs.unstable.tree-sitter-grammars.tree-sitter-nix
      pkgs.unstable.tree-sitter-grammars.tree-sitter-python
      pkgs.unstable.tree-sitter-grammars.tree-sitter-bash
      pkgs.unstable.tree-sitter-grammars.tree-sitter-regex
      pkgs.unstable.tree-sitter-grammars.tree-sitter-markdown
      pkgs.unstable.tree-sitter-grammars.tree-sitter-json

      pkgs.unstable.fzf
      pkgs.unstable.lazygit
      pkgs.unstable.lua-language-server
      pkgs.unstable.luajitPackages.jsregexp
      pkgs.unstable.nixd
      pkgs.unstable.stylua
      pkgs.unstable.shfmt
      pkgs.unstable.basedpyright
      pkgs.unstable.ruff
      pkgs.unstable.nixfmt
      pkgs.unstable.zls
      pkgs.unstable.ripgrep
      pkgs.unstable.chafa
    ];
  };
  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
      force = true;
    };
  };
}
