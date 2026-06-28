{ config, pkgs, ... }:

let
  gtkTheme = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };
  iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
  cursorTheme = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };
in
{
  home.packages = with pkgs; [
    adwaita-qt
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    nwg-look
  ];

  gtk = {
    enable = true;
    theme = gtkTheme;
    iconTheme = iconTheme;
    cursorTheme = cursorTheme;
    gtk4.theme = config.gtk.theme;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  home.pointerCursor = cursorTheme // {
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    GTK_THEME = gtkTheme.name;
    QT_STYLE_OVERRIDE = "adwaita-dark";
    XCURSOR_THEME = cursorTheme.name;
    XCURSOR_SIZE = toString cursorTheme.size;
    GDK_SCALE = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = gtkTheme.name;
    icon-theme = iconTheme.name;
    cursor-theme = cursorTheme.name;
  };
}
