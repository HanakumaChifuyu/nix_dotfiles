# Host-specific configuration for the home NAS.
# This intentionally imports only the core profile, not the desktop profile.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../configuration.nix
    ./hardware-configuration.nix
    ./disko.nix
  ];

  networking.hostName = "nas";
  time.timeZone = "Asia/Shanghai";

  # Keep the NAS reachable over SSH while avoiding desktop-oriented services.
  services.openssh.openFirewall = true;

  # Server hosts should default to a closed firewall and open ports explicitly.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
    allowPing = false;
  };
}
