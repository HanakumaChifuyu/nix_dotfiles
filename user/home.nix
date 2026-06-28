{
  imports = [
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/kitty.nix
    ./modules/matugen.nix
    ./modules/btop.nix
    ./modules/swaync.nix
    ./modules/waybar.nix
    ./modules/static-configs.nix
    ./modules/fontconfig.nix
    ./modules/themes.nix
    ./modules/fcitx5.nix
    ./modules/yazi.nix
    ./modules/git.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/ssh.nix
    ./modules/claude-code.nix
    ./modules/secrets.nix
    ./modules/activation.nix
    ./modules/portals.nix
    ./modules/xwayland.nix
    ./modules/registry.nix
  ];

  home.username = "tohno";
  home.homeDirectory = "/home/tohno";
  home.stateVersion = "26.05";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
