{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Allow unfree packages (required for corefonts, vistafonts, etc.)
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.code-new-roman

    # Victor Mono (hyprlock)
    victor-mono

    # CJK
    sarasa-gothic # 更纱黑体
    source-han-sans # 思源黑体 SC
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_zenhei
    wqy_microhei
    liberation_ttf

    # Microsoft-compatible fonts
    corefonts # Arial, Times New Roman, Verdana, etc.
    vista-fonts # Calibri, Cambria, Consolas, etc.

    dejavu_fonts
    noto-fonts-cjk-sans
    source-han-serif

    (pkgs.runCommand "ms-fonts" { } ''
      mkdir -p $out/share/fonts/mstype
      cp -r ${../user/fonts}/* $out/share/fonts/mstype/ '')
  ];

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
