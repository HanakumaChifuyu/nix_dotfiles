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
        nil # Nix
        lua-language-server # Lua
        basedpyright # Python
        tinymist # Typst
        rust-analyzer # Rust
        vtsls # JavaScript / TypeScript
        vscode-langservers-extracted # HTML / CSS / ESLint
        tailwindcss-language-server # Tailwind CSS
        emmet-ls # Emmet
        clang-tools # C / C++
        neocmakelsp # CMake
        mesonlsp # Meson
        sqls # SQL

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
        cmake-format
        meson
        sql-formatter # SQL Formatter
        sqlfluff # SQL Linter / Formatter

        fzf
        wordnet
      ])
      ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.macism ];
  };
}
