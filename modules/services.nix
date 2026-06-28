{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.udev.packages = [ pkgs.android-tools ];
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable touchpad support (enabled default in most desktopManager).
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
}
