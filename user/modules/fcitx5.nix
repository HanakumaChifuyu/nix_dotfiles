{ pkgs, lib, ... }:
{
  home.activation = {
    installRimeIce = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      RIME_DIR="$HOME/.local/share/fcitx5/rime"
      MARKER="$RIME_DIR/rime_ice.schema.yaml"
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/rime-ice"
      ZIP_FILE="$CACHE_DIR/rime-ice.zip"
      EXTRACT_DIR="$CACHE_DIR/extract"
      mkdir -p "$RIME_DIR"
      mkdir -p "$CACHE_DIR"
      if [ ! -f "$MARKER" ]; then
        if [ ! -f "$ZIP_FILE" ]; then
          ${pkgs.curl}/bin/curl -fSL -o "$ZIP_FILE" \
            "https://github.com/iDvel/rime-ice/releases/download/2026.06.03/full.zip"
        fi
        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        ${pkgs.unzip}/bin/unzip -o "$ZIP_FILE" -d "$EXTRACT_DIR"

        if [ ! -f "$EXTRACT_DIR/full/rime_ice.schema.yaml" ]; then
          echo "rime_ice.schema.yaml not found in rime-ice archive" >&2
          exit 1
        fi

        find "$RIME_DIR" -mindepth 1 -not -name rime_ice.userdb -exec rm -rf {} +
        cp -R "$EXTRACT_DIR/full/." "$RIME_DIR/"
        rm -rf "$EXTRACT_DIR"
        cp -f ${../dotfiles/rime/default.yaml} "$RIME_DIR/default.yaml"
      fi
    '';
  };

  xdg.configFile = {
    "fcitx5/profile" = {
      force = true;
      text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=rime

        [Groups/0/Items/0]
        Name=rime
        Layout=

        [Groups/0/Items/1]
        Name=keyboard-us
        Layout=

        [GroupOrder]
        0=Default
      '';
    };

    "fcitx5/config" = {
      force = true;
      text = ''
        [Hotkey]
        TriggerKeys=
        AltTriggerKeys=
        EnumerateForwardKeys=
        EnumerateBackwardKeys=
        ToggleIMEStateKeys=

        [Hotkey/TriggerKeys]
        0=Control+space

        [Behavior]
        ActiveByDefault=True
        PreloadInputMethod=True
        ActiveByMatchingInputMethodName=False
      '';
    };

    "fcitx5/conf/classicui.conf" = {
      force = true;
      text = ''
        # Vertical Candidate List
        Vertical Candidate List=False
        # Use mouse wheel to go to prev or next page
        WheelForPaging=True
        # Font
        Font="Sarasa Gothic SC 12"
        # Menu Font
        MenuFont="Sarasa Gothic SC 12"
        # Tray Font
        TrayFont="Sarasa Gothic SC 12"
        # Tray Label Outline Color
        TrayOutlineColor=#000000
        # Tray Label Text Color
        TrayTextColor=#ffffff
        # Prefer Text Icon
        PreferTextIcon=False
        # Show Layout Name In Icon
        ShowLayoutNameInIcon=True
        # Use input method language to display text
        UseInputMethodLanguageToDisplayText=True
        # Theme
        Theme=inflex-wechat
        # Dark Theme
        DarkTheme=inflex-wechat
        # Follow system light/dark color scheme
        UseDarkTheme=False
        # Follow system accent color if it is supported by theme and desktop
        UseAccentColor=True
        # Use Per Screen DPI on X11
        PerScreenDPI=False
        # Force font DPI on Wayland
        ForceWaylandDPI=0
        # Enable fractional scale under Wayland
        EnableFractionalScale=True

      '';
    };

    "fcitx5/addon/punctuation.conf".text = "GlobalHotkey=";
    "fcitx5/addon/quickphrase.conf".text = "ChooseKey=";
    "fcitx5/addon/chttrans.conf".text = "Hotkey=";
  };
}
