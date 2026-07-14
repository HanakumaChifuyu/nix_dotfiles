{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./i18n.nix
    ./user.nix
    ./packages.nix
    ./services.nix
    ./nix-settings.nix
    ./sops.nix
  ];

  # This value determines the NixOS release with which your system is aligned.
  system.stateVersion = "25.11";

  environment.variables = {
    CCACHE_MAXSIZE = "50G";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;
}
