{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.services.remoteDesktop.enable {
    # Supplies the package, uinput rules, discovery and streaming firewall ports.
    # labwc starts Sunshine as a child so it inherits this session's sockets.
    services.sunshine = {
      enable = true;
      # NVENC/CUDA support is selected at build time in this nixpkgs version.
      package = pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      };
      autoStart = false;
      openFirewall = true;
      capSysAdmin = false;
    };
  };
}
