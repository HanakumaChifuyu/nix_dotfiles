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
      set -gx HTTP_PROXY http://127.0.0.1:7890
      set -gx HTTPS_PROXY http://127.0.0.1:7890
      set -gx http_proxy http://127.0.0.1:7890
      set -gx https_proxy http://127.0.0.1:7890
      set -gx ALL_PROXY socks5://127.0.0.1:7890
      set -gx all_proxy socks5://127.0.0.1:7890
      set -gx NO_PROXY localhost,127.0.0.1,::1
      set -gx no_proxy localhost,127.0.0.1,::1
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
