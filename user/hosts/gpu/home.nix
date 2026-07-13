{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../home.nix ];

  # gpu-specific home configuration
  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 2.0 })
  '';
}
