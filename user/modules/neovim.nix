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

        # Build tools for lazy.nvim plugins such as nvim-treesitter and LuaSnip jsregexp.
        gcc
        gnumake
        tree-sitter

        # Formatter
        shfmt
        biome
        taplo
        xmlformat
        nixfmt # Nix formatter
        stylua # Lua formatter

        fzf
        wordnet
      ])
      ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.macism ];
  };
}
