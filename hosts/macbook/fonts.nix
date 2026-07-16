{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.code-new-roman

    sarasa-gothic
    source-han-sans
    source-han-serif
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_zenhei
    wqy_microhei
    liberation_ttf

    victor-mono
    dejavu_fonts

    corefonts
    vista-fonts

    (pkgs.runCommand "ms-fonts" { } ''
      mkdir -p $out/share/fonts/mstype
      cp -r ${../../user/fonts}/* $out/share/fonts/mstype/
    '')
  ];
}
