{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../home.nix ];

  # desktop-specific home configuration
  xresources.properties."Xft.dpi" = 96;

  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1.4 })
  '';

  home.packages = with pkgs; [
    wireplumber
    brightnessctl
    powertop
    codex

    # 社交网络
    wechat
    telegram-desktop
    vesktop
  ];
}
