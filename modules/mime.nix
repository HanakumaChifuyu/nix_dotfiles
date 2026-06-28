{ pkgs, ... }: {

  xdg.mime.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "image/*" = "satty.desktop";
    "video/mp4" = "mpv.desktop";
    "application/pdf" = "org.pwmt.zathura.desktop";

  };
}
