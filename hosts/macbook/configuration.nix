{ pkgs, ... }:

{
  imports = [
    ../../modules/nix-settings.nix
    ./fonts.nix
    ./homebrew.nix
    ./sing-box.nix
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

    defaults.NSGlobalDomain = {
      # Approximate Hyprland's repeat_rate = 60 and repeat_delay = 400.
      # macOS uses 15 ms units: 1 = ~67 repeats/s, 27 = ~405 ms delay.
      KeyRepeat = 1;
      InitialKeyRepeat = 27;
      ApplePressAndHoldEnabled = false;
    };

    defaults.CustomUserPreferences."NSGlobalDomain" = {
      AppleLanguages = [ "en-US" ];
      AppleLocale = "en_US";
    };
  };
}
