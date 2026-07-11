{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    vim
    lazygit
    podman-tui
    git
    wget
    curl
    htop
    tree
    file
    unzip
    zip
    ripgrep
    fd
    bat
    eza
    fzf
    tmux
    jq
    tokei

    # Hyprland ecosystem
    hypridle
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

    # Apps
    blueman
    zathura
    foot
    fontconfig
    claude-code
    vscode
    wechat
    feishu
    telegram-desktop
    wpsoffice-cn
    github-copilot-cli
    anki
    google-chrome
    scrcpy
    mpv
    vlc
    codex

    # Formatters (for Neovim conform.nvim)

    #game
    prismlauncher
    osu-lazer

    #develop
    ccache
    opencode

    # misc
    starship
    libnotify
    flclash

    wezterm
  ];
}
