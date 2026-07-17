{ pkgs, ... }:

let
  copyCommand = if pkgs.stdenv.hostPlatform.isDarwin then "pbcopy" else "wl-copy";
  proxyUrl = "http://127.0.0.1:7890";
  socksUrl = "socks5://127.0.0.1:7890";
  noProxy = "127.0.0.1,localhost,::1,100.64.0.0/10,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16";
in

{
  xdg.configFile."fish/config.fish".force = true;

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path --global $HOME/.local/bin/
      fish_vi_key_bindings
      set -x MANPAGER "nvim +Man!"
      set -g fish_greeting

      # Global proxy via local 7890 (sing-box mixed inbound)
      set -gx http_proxy '${proxyUrl}'
      set -gx https_proxy '${proxyUrl}'
      set -gx all_proxy '${socksUrl}'
      set -gx HTTP_PROXY '${proxyUrl}'
      set -gx HTTPS_PROXY '${proxyUrl}'
      set -gx ALL_PROXY '${socksUrl}'
      set -gx no_proxy '${noProxy}'
      set -gx NO_PROXY '${noProxy}'
    '';

    shellAliases = {
      lg = "lazygit";
      y = "yazi";
      vi = "nvim";
      ct = "code2prompt ./ | ${copyCommand}";
      svim = "sudoedit";
      ls = "eza --icons";
      ll = "eza -lgh --icons";
      lt = "eza --tree";
    };
  };
}
