{ pkgs, ... }:

{
  # Keep the base image intentionally small. Add a service in a host module or
  # create another shared module once two or more VPS hosts need it.
  environment.systemPackages = with pkgs; [
    curl
    git
    tmux
    vim
  ];
}
