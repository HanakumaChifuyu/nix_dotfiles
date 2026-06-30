{
  config,
  lib,
  pkgs,
  ...
}:

{
  #networking.hostName = "nixos";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  # Configure network proxy if necessary
  # networking.proxy.default = "https://proxy.hanakuma.uk";
  # networking.proxy.noProxy = "127.0.0.1,localhost,mirrors.tuna.tsinghua.edu.cn";
}
