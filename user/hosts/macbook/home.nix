{ pkgs, ... }:

{
  imports = [
    ../../modules/btop.nix
    ../../modules/fish.nix
    ../../modules/git.nix
    ../../modules/neovim.nix
    ../../modules/starship.nix
    ../../modules/ssh.nix
    ../../modules/yazi.nix
  ];

  home.username = "tohno";
  home.homeDirectory = "/Users/tohno";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    curl
    fd
    jq
    ripgrep
    tokei
    wget
    zoxide
  ];
}
