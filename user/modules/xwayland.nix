{ lib, ... }:
{
  xresources.properties = {

    "Xft.dpi" = lib.mkDefault 192;
    "Xft.autohint" = 0;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintslight";
    "Xft.hinting" = 1;
    "Xft.antialiasing" = 1;
    "Xft.rgba" = "rgb";

  };
}
