{
  lib,
  pkgs,
  ...
}:
{
  programs.neovim.enable = true;
  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    pkgs.vimPlugins.nvim-treesitter
  ];
  programs.neovim.extraPackages = [
    pkgs.tree-sitter-grammars.tree-sitter-c
    pkgs.tree-sitter-grammars.tree-sitter-cpp
    pkgs.tree-sitter-grammars.tree-sitter-cmake
    pkgs.clang-tools

    pkgs.tree-sitter
    pkgs.lua54Packages.jsregexp
    pkgs.tree-sitter-grammars.tree-sitter-lua
    pkgs.tree-sitter-grammars.tree-sitter-nix
    pkgs.tree-sitter-grammars.tree-sitter-go
    pkgs.tree-sitter-grammars.tree-sitter-python
    pkgs.tree-sitter-grammars.tree-sitter-bash
    pkgs.tree-sitter-grammars.tree-sitter-regex
    pkgs.tree-sitter-grammars.tree-sitter-markdown
    pkgs.tree-sitter-grammars.tree-sitter-json

    pkgs.nodejs_24
    pkgs.nodePackages_latest.vscode-json-languageserver
    pkgs.fzf
    pkgs.lazygit
    pkgs.lua-language-server
    pkgs.luajitPackages.jsregexp
    pkgs.nixd
    pkgs.go
    pkgs.gopls
    pkgs.gofumpt
    pkgs.stylua
    pkgs.cargo
    pkgs.rustc
    pkgs.basedpyright
    pkgs.terraform-ls
    pkgs.terraform-lsp
    pkgs.dart
    pkgs.ruff
    pkgs.nixfmt-rfc-style
    pkgs.starlark-rust
    pkgs.zls
    pkgs.ripgrep
    pkgs.ueberzugpp
    pkgs.viu
    pkgs.chafa
    pkgs.delve
    pkgs.imagemagick
  ];
  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
      force = true;
    };
  };
}
