{ config, ... }:

{
  xdg.configFile."ghostty/config.ghostty".source = ../../dotfiles/.config/ghostty/config.ghostty;
  xdg.configFile."ghostty/themes/Matugen" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.cache/matugen/ghostty-theme.conf";
    force = true;
  };
}
