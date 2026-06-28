{ config, pkgs, ... }:

let
  home = toString config.home.homeDirectory;
  swayncPackage = pkgs.swaynotificationcenter;
in
{
  services.swaync = {
    enable = true;
    package = swayncPackage;
    style = config.lib.file.mkOutOfStoreSymlink (home + "/.cache/matugen/swaync-style.css");
    settings = {
      "$schema" = "file://${swayncPackage}/share/swaync/configSchema.json";
      positionX = "right";
      positionY = "top";
      layer = "top";
      control-center-layer = "top";
      control-center-width = 420;
      control-center-height = 860;
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-window-width = 420;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = true;
      hide-on-action = true;
      script-fail-notify = true;

      widgets = [
        "title"
        "dnd"
        "notifications"
        "mpris"
      ];

      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };

        dnd = {
          text = "Do Not Disturb";
        };

        mpris = {
          image-size = 96;
        };
      };
    };
  };
}
