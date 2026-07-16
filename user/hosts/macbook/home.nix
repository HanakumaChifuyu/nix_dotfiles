{ pkgs, ... }:

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
  ];

  home.username = "mac";
  home.homeDirectory = "/Users/mac";
  home.stateVersion = "26.05";

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
  ];
}
