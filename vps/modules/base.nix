{ lib, ... }:

{
  time.timeZone = "Asia/Shanghai";

  # Most VPS providers supply their primary interface through DHCP. Override
  # this in an individual host only when the provider requires static network
  # configuration.
  networking.useDHCP = lib.mkDefault true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "25.11";
}
