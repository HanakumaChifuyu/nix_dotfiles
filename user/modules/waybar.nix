let
  dots = ../dotfiles/.config/waybar;
in
{
  programs.waybar.enable = true;

  xdg.configFile."waybar" = {
    source = dots;
    recursive = true;
    force = true;
  };
}
