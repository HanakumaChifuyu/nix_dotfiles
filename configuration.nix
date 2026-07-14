# Core configuration for all NixOS hosts.
# Desktop hosts should also import ./modules/desktop.nix.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./modules/core.nix
  ];
}
