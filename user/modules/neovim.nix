{ lib, pkgs, ... }:

{
  xdg.configFile."nvim" = {
    source = ../dotfiles/.config/nvim;
    recursive = true;
    force = true;
  };
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages =
      (with pkgs; [
        # LSP
        nixd # Nix LSP
        lua-language-server # Lua
        basedpyright # Python
        gopls # Go
        vtsls # TypeScript
        tinymist # Typsty
        rust-analyzer # Rust
        clang-tools # cpp
        neocmakelsp # cmake
        mesonlsp

        # Build tools for lazy.nvim plugins such as nvim-treesitter and LuaSnip jsregexp.
        gcc
        gnumake
        tree-sitter

        # Formatter
        rustfmt
        shfmt
        prettier
        biome
        taplo
        xmlformat
        google-java-format
        nixfmt # Nix formatter
        stylua # Lua formatter
        black # Python formatter
        gersemi # cmake formatter

        fzf
        wordnet
      ])
      ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.macism ];
  };
}
