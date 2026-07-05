{ pkgs, ... }:

{
  xdg.configFile."fish/config.fish".force = true;

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path --global $HOME/.local/bin/
      fish_vi_key_bindings
      set -x MANPAGER "nvim +Man!"
      set -g fish_greeting
    '';

    shellAliases = {
      lg = "lazygit";
      y = "yazi";
      vi = "nvim";
      ct = "code2prompt ./ | wl-copy";
      svim = "sudoedit";
      ls = "eza --icons";
      ll = "eza -lgh --icons";
      lt = "eza --tree";
    };
  };
}
