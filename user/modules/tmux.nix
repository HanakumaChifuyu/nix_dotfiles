{ lib, pkgs, ... }:

let
  tmuxConfigDir = ../dotfiles/.config/tmux;
  mainConfig = lib.replaceStrings
    [
      ''source-file ~/.config/tmux/shortcuts.conf
source-file ~/.config/tmux/navigation.conf
source-file ~/.config/tmux/plugins.conf
''
    ]
    [ "" ]
    (builtins.readFile (tmuxConfigDir + /tmux.conf));
in
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    sensibleOnTop = true;

    extraConfig = ''
      ${mainConfig}
      ${builtins.readFile (tmuxConfigDir + /shortcuts.conf)}
      ${builtins.readFile (tmuxConfigDir + /navigation.conf)}

      # Keep plugins after the status configuration: cpu and prefix-highlight
      # replace their placeholders when their entrypoints are sourced.
      run-shell ${pkgs.tmuxPlugins.yank.rtp}
      run-shell ${pkgs.tmuxPlugins.prefix-highlight.rtp}
      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.tmux-fzf.rtp}
      run-shell ${pkgs.tmuxPlugins.open.rtp}
    '';
  };

  # tmux-fzf invokes fzf at runtime.
  home.packages = [ pkgs.fzf ];
}
