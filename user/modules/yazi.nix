{ config, pkgs, ... }:

let
  dots = ../dotfiles/.config/yazi;

  setYaziAsFileManager =
    { isDarwin, isLinux }:
    if isDarwin then
      { }
    else if isLinux then
      {
        # Set Yazi as the system file chooser.
        "xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
          source = ../dotfiles/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh;
          force = true;
          executable = true;
        };

        "xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${config.xdg.configHome}/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=PATH="$PATH:/run/current-system/sw/bin"
          open_mode = suggested
          save_mode = last
        '';
      }
    else
      { };
in
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    enableFishIntegration = true;
    extraPackages = [
      pkgs.ouch
    ];
    settings = builtins.fromTOML (builtins.readFile "${dots}/yazi.toml");
    keymap = builtins.fromTOML (builtins.readFile "${dots}/keymap.toml");
    plugins.ouch = dots + /plugins/ouch.yazi;

  };

  xdg.configFile = setYaziAsFileManager {
    inherit (pkgs.stdenv) isDarwin isLinux;
  };
}
