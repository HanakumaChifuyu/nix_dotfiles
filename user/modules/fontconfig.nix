{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        "Source Han Sans SC"
        "Noto Sans CJK SC"
        "DejaVu Sans"
      ];

      serif = [
        "Source Han Serif SC"
        "Noto Serif CJK SC"
        "DejaVu Serif"
      ];

      monospace = [ "Source Han Sans SC" ];
    };
  };
}
