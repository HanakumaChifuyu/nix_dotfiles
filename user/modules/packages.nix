{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    tokei

    # Hyprland ecosystem
    hypridle
    wofi
    rofi
    fuzzel
    awww
    wl-clipboard
    cliphist
    grim
    slurp
    wf-recorder
    hyprpolkitagent
    wiremix
    pamixer
    playerctl
    satty
    xdg-desktop-portal-termfilechooser

    # Theming
    matugen

    # Apps (Lightweight/Essentials)
    blueman
    zathura
    foot
    fontconfig
    scrcpy
    mpv

    # Formatters (for Neovim conform.nvim)

    # misc
    starship
    libnotify
    flclash

    wezterm
  ];
}
