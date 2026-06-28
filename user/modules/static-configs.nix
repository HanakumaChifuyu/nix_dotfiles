let
  dots = ../dotfiles/.config;
  forceSource = source: {
    inherit source;
    force = true;
    recursive = true;
  };
in
{
  xdg.configFile = {
    foot = forceSource "${dots}/foot";
    fuzzel = forceSource "${dots}/fuzzel";
    htop = forceSource "${dots}/htop";
    hypr = forceSource "${dots}/hypr_lua";
    rofi = forceSource "${dots}/rofi";
    zathura = forceSource "${dots}/zathura";
  };
}
