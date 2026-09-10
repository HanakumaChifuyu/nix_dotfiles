{ pkgs, unstable, ... }:

{
  imports = [
    ../../modules/btop.nix
    ../../modules/fish.nix
    ../../modules/git.nix
    ../../modules/kitty.nix
    ../../modules/matugen.nix
    ../../modules/neovim.nix
    ../../modules/starship.nix
    ../../modules/ssh.nix
    ../../modules/tmux.nix
    ../../modules/yazi.nix
    ./karabiner.nix
    ./rime.nix
  ];

  home.username = "tohno";
  home.homeDirectory = "/Users/tohno";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  programs.man.generateCaches = false;

  # tmux navigation uses M-* bindings; make macOS Option emit Alt in Kitty.
  programs.kitty.settings.macos_option_as_alt = "both";

  home.packages = with pkgs; [
    age
    curl
    code2prompt
    eza
    fd
    home-manager
    jq
    lazygit
    ripgrep
    sops
    tokei
    wget
    zoxide
    unstable.codex
  ];
}
