{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:

{
  imports = [
    ../../home.nix
    ../../modules/wechat.nix
  ];

  # Desktop 使用 1x 输出缩放，并单独放大文字，避免低 DPI 屏幕上的
  # fractional scaling 使界面和字体发虚。
  xresources.properties."Xft.dpi" = lib.mkForce 120;

  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1.0 })
  '';

  # 96 DPI * 1.25：只放大字体，不改变 Hyprland 的逻辑像素缩放。
  home.sessionVariables.QT_FONT_DPI = "120";

  gtk.font = {
    name = "Source Han Sans SC";
    size = 13;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    font-name = "Source Han Sans SC 13";
    document-font-name = "Source Han Sans SC 13";
    monospace-font-name = "JetBrainsMono Nerd Font 13";
    text-scaling-factor = 1.25;
  };

  programs.kitty.font.size = lib.mkForce 14.0;

  fonts.fontconfig = {
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";

    configFile."desktop-lcd-rendering" = {
      priority = 90;
      text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <match target="font">
            <edit name="antialias" mode="assign"><bool>true</bool></edit>
            <edit name="hinting" mode="assign"><bool>true</bool></edit>
            <edit name="autohint" mode="assign"><bool>false</bool></edit>
            <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
            <edit name="rgba" mode="assign"><const>rgb</const></edit>
            <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
          </match>
        </fontconfig>
      '';
    };
  };

  home.packages = with pkgs; [
    wireplumber
    brightnessctl
    powertop
    unstable.codex

    # 社交网络
    wechat
    telegram-desktop
    vesktop
  ];
}
