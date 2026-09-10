{ pkgs, ... }:

{
  imports = [
    ../../modules/nix-settings.nix
    ./fonts.nix
    ./homebrew.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "macbook";

  users.users.tohno = {
    home = "/Users/tohno";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  system = {
    primaryUser = "tohno";
    stateVersion = 6;

    defaults.CustomUserPreferences."NSGlobalDomain" = {
      AppleLanguages = [ "en-US" ];
      AppleLocale = "en_US";
    };
  };
}
