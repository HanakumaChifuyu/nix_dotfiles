{ pkgs, ... }:

let
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

      # Proxy only applies to this Fish session and processes launched from it.
      set -gx http_proxy '${proxyUrl}'
      set -gx https_proxy '${proxyUrl}'
      set -gx all_proxy '${socksUrl}'
      set -gx HTTP_PROXY '${proxyUrl}'
      set -gx HTTPS_PROXY '${proxyUrl}'
      set -gx ALL_PROXY '${socksUrl}'
      set -gx no_proxy '${noProxy}'
      set -gx NO_PROXY '${noProxy}'

      # Steam and games can fail to connect through a generic HTTP/SOCKS proxy.
      # Desktop launchers do not inherit Fish variables; this covers `steam`
      # started directly from a Fish terminal as well.
      function steam --description "Start Steam without shell proxy variables"
        env \
          -u http_proxy -u https_proxy -u all_proxy \
          -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
          -u no_proxy -u NO_PROXY \
          steam $argv
      end

      # Interactive SSH host selector using fzf
      function s --description "Interactive SSH host selector with fzf"
        if test (count $argv) -gt 0
          command ssh $argv
          return
        end

        set -l host (grep -iE '^Host ' ~/.ssh/config | awk '{print $2}' | grep -v '\*' | fzf --height 40% --reverse --prompt="SSH > " --header="Select SSH Server to connect:")
        if test -n "$host"
          echo "Connecting to $host..."
          command ssh $host
        end
      end
    '';

    shellAliases = {
      lg = "lazygit";
      y = "yazi";
      ls = "eza --icons";
      ll = "eza -lgh --icons";
      lt = "eza --tree";
      ss = "sshs";
    };
  };
}
