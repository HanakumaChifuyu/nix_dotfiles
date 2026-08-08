{
  config,
  lib,
  pkgs,
  ...
}:

{
  # nix-ld: run unpatched dynamic binaries on NixOS
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    glib
    gtk3
    dbus
    atk
    at-spi2-atk
    at-spi2-core

    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    libxi
    libxcursor
    libxxf86vm
    libxcb
    libpciaccess

    cairo
    pango
    gdk-pixbuf
    freetype
    fontconfig
    libxshmfence
    libglvnd

    # Chromium / WebKit
    nspr
    nss
    cups
    expat
    libdrm
    mesa
    libgbm
    libxkbcommon
    alsa-lib

    icu
    libuuid
    libjpeg
    libpng
    sqlite

    wezterm
  ];
  programs.hyprlock.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.steam = {
    enable = true;
    fontPackages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
  };

}
