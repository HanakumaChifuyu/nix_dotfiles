{
  config,
  pkgs,
  unstable,
  ...
}:
{
  # WeChat still needs the GTK Fcitx module under XWayland.  Keep this scoped
  # to its launcher so native Wayland GTK applications use the Wayland frontend.
  xdg.desktopEntries.wechat = {
    name = "wechat";
    exec = "${pkgs.coreutils}/bin/env GTK_IM_MODULE=fcitx ${pkgs.wechat}/bin/wechat %U";
    icon = "wechat";
    terminal = false;
    categories = [ "Utility" ];
  };

}
