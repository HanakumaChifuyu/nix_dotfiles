# Host-specific configuration for desktop-nixos
# Extends the base configuration.nix with host-specific overrides

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../configuration.nix
    ../../modules/desktop.nix
    ../../hardware-configuration.nix
  ];

  # Host-specific settings override the base configuration

  # Zen kernel: optimized for desktop responsiveness and low latency
  boot.kernelPackages = pkgs.linuxPackages_zen;

  time.timeZone = "Asia/Shanghai";
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

  };
  networking.hostName = "desktop_nixos";
}
