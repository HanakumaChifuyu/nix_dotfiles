{
  config,
  pkgs,
  unstable,
  ...
}:

{
  imports = [
    ../../home.nix
    ../../modules/wechat.nix
  ];

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
    unstable.codex

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

    # node
    nodejs_26
    pnpm
  ];

  xdg.configFile."hypr/modules/monitor.lua".text = ''
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 2.0 })
  '';
}
