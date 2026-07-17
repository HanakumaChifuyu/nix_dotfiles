{ pkgs, unstable, ... }:

{
  imports = [
    ../../modules/btop.nix
    ../../modules/fish.nix
    ../../modules/git.nix
    ../../modules/kitty.nix
    ../../modules/neovim.nix
    ../../modules/starship.nix
    ../../modules/ssh.nix
    ../../modules/yazi.nix
    ./karabiner.nix
    ./rime.nix
  ];

  home.username = "mac";
  home.homeDirectory = "/Users/mac";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  programs.man.generateCaches = false;

  home.packages = with pkgs; [
    curl
    code2prompt
    eza
    fd
    home-manager
    jq
    lazygit
    ripgrep
    tokei
    wget
    zoxide
    unstable.codex
  ];
}
