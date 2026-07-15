{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../home.nix ];

  # desktop-specific home configuration
  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1.2 })
  '';

  home.packages = with pkgs; [
    wireplumber
    brightnessctl
    powertop
    codex
  ];
}
