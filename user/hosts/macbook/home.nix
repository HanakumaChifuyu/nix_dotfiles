{
  lib,
  pkgs,
  unstable,
  ...
}:

{
  imports = [
    ../../modules/btop.nix
    ../../modules/fish.nix
    ../../modules/git.nix
    # ../../modules/kitty.nix
    ../../modules/matugen.nix
    ../../modules/neovim.nix
    ../../modules/starship.nix
    ../../modules/ssh.nix
    ../../modules/tmux.nix
    ../../modules/yazi.nix
    ./ghostty.nix
    ./karabiner.nix
    ./rime.nix
    ./sol.nix
  ];

  home.username = "tohno";
  home.homeDirectory = "/Users/tohno";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  programs.man.generateCaches = false;

  # programs.kitty.settings = {
  #   # Karabiner turns the physical Command keys into macOS Option; make Kitty
  #   # treat those logical Option keys as Alt for tmux navigation.
  #   macos_option_as_alt = "both";
  #
  #   # Use native macOS transparency and background blur.
  #   background_opacity = 0.9;
  #   background_blur = 20;
  # };

  home.file.".local/bin/mac-screenshot" = {
    executable = true;
    text = ''
      #!/bin/sh

      set -eu

      screenshots_dir="$HOME/Pictures/Screenshots"
      /bin/mkdir -p "$screenshots_dir"

      timestamp=$(/bin/date '+%Y%m%d%H%M%S')
      base_path="$screenshots_dir/screenshot_$timestamp"
      screenshot_path="$base_path.png"
      suffix=1

      while [ -e "$screenshot_path" ]; do
        screenshot_path="''${base_path}_$suffix.png"
        suffix=$((suffix + 1))
      done

      if ! /usr/sbin/screencapture -i -s -t png "$screenshot_path"; then
        /bin/rm -f "$screenshot_path"
        exit 0
      fi

      # Cancelling interactive capture can return without creating an image.
      if [ ! -s "$screenshot_path" ]; then
        /bin/rm -f "$screenshot_path"
        exit 0
      fi

      /usr/bin/osascript - "$screenshot_path" <<'APPLESCRIPT'
      on run argv
        set screenshotPath to item 1 of argv
        set screenshotFile to POSIX file screenshotPath
        set the clipboard to (read screenshotFile as «class PNGf»)
        display notification "已保存并复制到剪贴板" with title "截图完成" subtitle screenshotPath
      end run
      APPLESCRIPT

      /usr/bin/afplay -v 0.35 /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
    '';
  };

  home.file.".local/bin/mac-space-check" = {
    executable = true;
    text = ''
      #!/bin/sh

      set -eu

      target_space="''${1:-}"

      notify() {
        /usr/bin/osascript - "$1" <<'APPLESCRIPT'
      on run argv
        display notification (item 1 of argv) with title "桌面切换"
      end run
      APPLESCRIPT
      }

      case "$target_space" in
        1|2|3|4|5|6|7|8|9|10) ;;
        *)
          notify "无效的桌面编号：$target_space"
          exit 0
          ;;
      esac

      space_count=$(
        /usr/bin/defaults export com.apple.spaces - 2>/dev/null \
          | /usr/bin/plutil \
              -extract 'SpacesDisplayConfiguration.Management Data.Monitors' \
              json -o - - \
          | ${pkgs.jq}/bin/jq -er \
              '[.[] | select(."Display Identifier" == "Main") | .Spaces[]? | select(.type == 0)] | length'
      ) || {
        notify "无法读取主显示器的桌面列表"
        exit 0
      }

      if [ "$target_space" -gt "$space_count" ]; then
        notify "桌面 $target_space 尚未创建（当前共 $space_count 个）"
      fi
    '';
  };

  # Mission Control owns native Space switching. Keep its Control+1 through
  # Control+0 shortcuts enabled, while preserving every unrelated symbolic
  # hotkey already configured by the user. Karabiner emits these shortcuts
  # after checking whether the requested Space exists.
  home.activation.enableMacDesktopShortcuts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    enable_desktop_shortcut() {
      shortcut_id="$1"
      key_code="$2"
      shortcut_value="<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>$key_code</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"

      /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
        -dict-add "$shortcut_id" "$shortcut_value"
    }

    enable_desktop_shortcut 118 18
    enable_desktop_shortcut 119 19
    enable_desktop_shortcut 120 20
    enable_desktop_shortcut 121 21
    enable_desktop_shortcut 122 23
    enable_desktop_shortcut 123 22
    enable_desktop_shortcut 124 26
    enable_desktop_shortcut 125 28
    enable_desktop_shortcut 126 25
    enable_desktop_shortcut 127 29
  '';

  home.packages = with pkgs; [
    age
    curl
    code2prompt
    eza
    fd
    home-manager
    jq
    lazygit
    ripgrep
    sops
    tokei
    wget
    zoxide
    unstable.codex
    ncdu

    # social network
    telegram-desktop

  ];
}
