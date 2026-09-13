{ pkgs, ... }:

{
  imports = [
    ../../modules/nix-settings.nix
    ./fonts.nix
    ./homebrew.nix
    ./sing-box.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # 定期自动清理未引用的 Nix 包与旧代际（每周日凌晨 03:15 清理超过 7 天的旧代际）
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 7;
      Hour = 3;
      Minute = 15;
    };
    options = "--delete-older-than 7d";
  };

  # 定期自动优化 Nix store（通过硬链接去重）
  nix.optimise.automatic = true;

  networking.hostName = "macbook";

  users.users.tohno = {
    home = "/Users/tohno";
    shell = pkgs.fish;
  };

  # Allow the primary macOS user to administer the machine without entering
  # their password after login.
  security.sudo.extraConfig = ''
    tohno ALL = (ALL) NOPASSWD: ALL
  '';

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

    # The implicit macOS mouse tracking speed is 1.0. Increase mouse movement
    # by 50% without changing the trackpad speed.
    defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;

    # Keep Desktop 1-10 numbering stable for Alt+number switching.
    defaults.dock.mru-spaces = false;

    defaults.CustomUserPreferences."NSGlobalDomain" = {
      AppleLanguages = [ "en-US" ];
      AppleLocale = "en_US";
    };
  };
}
