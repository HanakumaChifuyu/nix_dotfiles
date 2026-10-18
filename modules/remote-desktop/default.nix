{ config, lib, ... }:

let
  cfg = config.services.remoteDesktop;
in
{
  imports = [ ./labwc.nix ./sunshine.nix ];

  options.services.remoteDesktop = {
    enable = lib.mkEnableOption "an on-demand headless labwc / Sunshine session";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Existing normal user allowed to run the remote session.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user}.extraGroups = [ "video" "render" "seat" ];
    services.seatd.enable = true;
  };
}
