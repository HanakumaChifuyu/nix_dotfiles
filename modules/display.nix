{ config, lib, pkgs, ... }:

{
  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Display manager
  services.displayManager.ly.enable = true;

  # Hyprland (Wayland) - using nixpkgs built-in version (binary cache guaranteed)
  programs.hyprland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
}
