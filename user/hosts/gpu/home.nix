{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../home.nix ];

  # gpu-specific home configuration
  home.packages = with pkgs; [
    # Games (Minecraft, Osu!)
    prismlauncher
    osu-lazer

    # Development & AI Tools
    vscode
    ccache
    opencode
    claude-code
    github-copilot-cli
    codex

    # Social & Communication
    wechat
    feishu
    telegram-desktop

    # Office & Productivity
    wpsoffice-cn
    anki

    # Media
    vlc

    # Browsers
    qutebrowser
    google-chrome
  ];

  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 2.0 })
  '';
}
