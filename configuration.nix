# Base configuration for all NixOS hosts
# Import this in each host-specific configuration and override as needed

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/i18n.nix
    ./modules/display.nix
    ./modules/audio.nix
    ./modules/user.nix
    ./modules/bluetooth.nix
    ./modules/fonts.nix
    ./modules/programs.nix
    ./modules/packages.nix
    ./modules/services.nix
    ./modules/nix-settings.nix
    ./modules/vitualisation.nix
    ./modules/sing-box.nix
    ./modules/sops.nix
    ./modules/mime.nix
  ];

  # This value determines the NixOS release with which your system is aligned.
  system.stateVersion = "25.11";

  environment.variables = {

    CCACHE_MAXSIZE = "50G";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;
}
