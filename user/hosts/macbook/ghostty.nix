{ config, ... }:

{
  xdg.configFile."ghostty/config.ghostty".text =
    builtins.readFile ../../dotfiles/.config/ghostty/config.ghostty
    + ''

      command = /run/current-system/sw/bin/fish
    '';
  xdg.configFile."ghostty/themes/Matugen" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.cache/matugen/ghostty-theme.conf";
    force = true;
  };
}
