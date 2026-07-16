{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "macbook";

  users.users.mac = {
    home = "/Users/mac";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  system = {
    primaryUser = "mac";
    stateVersion = 6;
  };
}
