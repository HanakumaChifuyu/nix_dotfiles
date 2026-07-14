{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./display.nix
    ./audio.nix
    ./bluetooth.nix
    ./fonts.nix
    ./programs.nix
    ./mime.nix
    ./vitualisation.nix
    ./sing-box.nix
  ];

  # Chinese input method for graphical sessions.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-gtk
      fcitx5-inflex-themes
    ];
  };

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  services.udev.packages = [ pkgs.android-tools ];

  users.users.tohno.extraGroups = [
    "video"
    "audio"
    "docker"
    "adbusers"
    "podman"
  ];

  # Enable touchpad support for desktop sessions.
  services.libinput.enable = true;

  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          global = {
            tap_timeout = 20;
          };

          main = {
            pageup = "macro2(100, 100, scrollup)";
            pagedown = "macro2(100, 100, scrolldown)";
            capslock = "esc";

            leftalt = "leftmeta";
            leftmeta = "leftalt";
          };

          control = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
          };

          "control+shift" = {
            h = "C-S-h";
            j = "C-S-j";
            k = "C-S-k";
            l = "C-S-l";
          };
        };
      };
    };
  };

  systemd.packages = [ pkgs.xdg-desktop-portal-termfilechooser ];
  systemd.services."xdg-desktop-portal-termfilechooser".wantedBy = [ "multi-user.target" ];

  environment.systemPackages = with pkgs; [
    xrdb
    android-tools
    ffmpeg
    v4l-utils
  ];
}
