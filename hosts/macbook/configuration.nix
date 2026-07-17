{ pkgs, ... }:

{
  imports = [
    ../../modules/nix-settings.nix
    ./fonts.nix
    ./homebrew.nix
    ./yabai.nix
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

    defaults.CustomUserPreferences."NSGlobalDomain" = {
      AppleLanguages = [ "en-US" ];
      AppleLocale = "en_US";
    };
  };
}
