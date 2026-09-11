{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = toString config.home.homeDirectory;
  wallpapers = ../Wallpapers;
  matugenSource = ../dotfiles/.config/matugen;
  nvimTemplate = ../dotfiles/.config/nvim/lua/matugen-template.lua;
  cacheLink = path: config.lib.file.mkOutOfStoreSymlink (home + "/.cache/matugen/" + path);
  walLink = path: config.lib.file.mkOutOfStoreSymlink (home + "/.cache/wal/" + path);

  sharedOutputs = [
    "${home}/.cache/wal/colors.json"
    "${home}/.cache/matugen/kitty-colors.conf"
    "${home}/.cache/matugen/btop.theme"
    "${home}/.cache/matugen/yazi-theme.toml"
    "${home}/.cache/matugen/nvim-matugen.lua"
  ];

  linuxOutputs = [
    "${home}/.cache/wal/colors-waybar.css"
    "${home}/.cache/matugen/hypr-vars.conf"
    "${home}/.cache/matugen/hyprland-bindings.conf"
    "${home}/.cache/matugen/hypr-vars.lua"
    "${home}/.cache/matugen/fuzzel-colors.ini"
    "${home}/.cache/matugen/foot-colors.ini"
    "${home}/.cache/matugen/mako-colors"
  ];

  ensureMatugenColors =
    {
      generationId,
      hookPath,
      requiredOutputs,
    }:
    lib.hm.dag.entryAfter ([ "linkGeneration" ] ++ lib.optionals pkgs.stdenv.isDarwin [ "installSquirrelRimeIce" ]) ''
      generation_id='${generationId}'
      generation_marker="${home}/.cache/matugen/.generation"
      needs_generation=0

      if [[ ! -r "$generation_marker" ]] || [[ "$(<"$generation_marker")" != "$generation_id" ]]; then
        needs_generation=1
      else
        for output in ${lib.escapeShellArgs requiredOutputs}; do
          if [[ ! -s "$output" ]]; then
            needs_generation=1
            break
          fi
        done
      fi

      if [[ "$needs_generation" -eq 1 ]]; then
        mkdir -p "${home}/.cache/matugen" "${home}/.cache/wal"

        wallpaper=""
        if [[ -s "${home}/.cache/matugen/current_wallpaper" ]]; then
          candidate="$(<"${home}/.cache/matugen/current_wallpaper")"
          if [[ -f "$candidate" ]]; then
            wallpaper="$candidate"
          fi
        fi

        if [[ -z "$wallpaper" ]]; then
          for candidate in "${wallpapers}"/*; do
            case "''${candidate,,}" in
              *.jpg|*.jpeg|*.png|*.webp)
                wallpaper="$candidate"
                break
                ;;
            esac
          done
        fi

        if [[ -n "$wallpaper" ]]; then
          echo "Generating initial matugen colors from $wallpaper"
          SHELL="${pkgs.bash}/bin/bash" \
          PATH="${hookPath}:$PATH" \
          MATUGEN_DEFER_HYPR_RELOAD=1 \
            ${pkgs.matugen}/bin/matugen image "$wallpaper" --mode dark --type scheme-tonal-spot --contrast 0 --source-color-index 0
          printf '%s\n' "$generation_id" > "$generation_marker"
          printf '%s\n' "$wallpaper" > "${home}/.cache/matugen/current_wallpaper"
        else
          echo "No wallpaper found in ${wallpapers}; skipping initial matugen color generation"
        fi
      fi
    '';

  applySquirrelColors = pkgs.writeShellScript "apply-squirrel-colors" ''
    set -eu
    mkdir -p "${home}/Library/Rime"
    # Matugen emits RGB/ARGB; Squirrel expects BGR/ABGR. Convert 8-digit
    # colors first so their alpha byte remains at the front.
    ${pkgs.gnused}/bin/sed -E \
      -e 's/0x([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})([^[:xdigit:]]|$)/0x\1\4\3\2\5/g' \
      -e 's/0x([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})([^[:xdigit:]]|$)/0x\3\2\1\4/g' \
      "${home}/.cache/matugen/squirrel-colors.yaml" > "${home}/Library/Rime/matugen.yaml"
    squirrel="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
    if [ -x "$squirrel" ]; then
      "$squirrel" --reload
    fi
  '';

  darwinConfig = pkgs.writeText "matugen-darwin.toml" ''
    [config]
    [config.wallpaper]
    command = "/bin/sh"
    arguments = ["${home}/.config/matugen/set-wallpaper"]
    set = true

    [templates]

    [templates.kitty]
    input_path = "~/.config/matugen/templates/kitty-colors.conf"
    output_path = "~/.cache/matugen/kitty-colors.conf"
    post_hook = "/usr/bin/pkill -SIGUSR1 kitty || true"

    [templates.btop]
    input_path = "~/.config/matugen/templates/btop.theme"
    output_path = "~/.cache/matugen/btop.theme"

    [templates.yazi]
    input_path = "~/.config/matugen/templates/yazi-theme.toml"
    output_path = "~/.cache/matugen/yazi-theme.toml"

    [templates.nvim]
    input_path = "~/.config/nvim/lua/matugen-template.lua"
    output_path = "~/.cache/matugen/nvim-matugen.lua"
    post_hook = "/usr/bin/pkill -SIGUSR1 nvim || true"

    [templates.pywal]
    input_path = "~/.config/matugen/templates/pywal-colors.json"
    output_path = "~/.cache/wal/colors.json"

    [templates.squirrel]
    input_path = "~/.config/matugen/templates/squirrel-colors.yaml"
    output_path = "~/.cache/matugen/squirrel-colors.yaml"
    post_hook = "${applySquirrelColors}"
  '';

  mkLinuxConfig = _: {
    home.packages = [ pkgs.matugen ];

    xdg.configFile."matugen" = {
      source = matugenSource;
      force = true;
    };
    xdg.configFile."waybar/colors.css" = {
      source = walLink "colors-waybar.css";
      force = true;
    };
    xdg.configFile."btop/themes/matugen.theme" = {
      source = cacheLink "btop.theme";
      force = true;
    };
    xdg.configFile."yazi/theme.toml" = {
      source = cacheLink "yazi-theme.toml";
      force = true;
    };
    xdg.configFile."nvim/lua/matugen.lua" = {
      source = cacheLink "nvim-matugen.lua";
      force = true;
    };
    xdg.configFile."hypr/hypr-vars.lua" = {
      source = cacheLink "hypr-vars.lua";
      force = true;
    };

    home.activation.ensureMatugenColors = ensureMatugenColors {
      generationId = "${matugenSource}:${nvimTemplate}:linux";
      hookPath = lib.makeBinPath [
        pkgs.bash
        pkgs.coreutils
        pkgs.matugen
        pkgs.mako
        pkgs.procps
        pkgs.awww
      ];
      requiredOutputs = sharedOutputs ++ linuxOutputs;
    };

    # Home Manager starts mako through D-Bus activation. Reload that single
    # instance instead of starting a competing service.
    home.activation.reloadMako = lib.hm.dag.entryAfter [ "ensureMatugenColors" ] ''
      ${pkgs.systemd}/bin/systemctl --user reset-failed mako.service >/dev/null 2>&1 || true
      ${pkgs.mako}/bin/makoctl reload >/dev/null 2>&1 || true
    '';
  };

  mkDarwinConfig = _: {
    home.packages = [ pkgs.matugen ];

    home.file.".local/bin/matugen-wallpaper" = {
      executable = true;
      text = ''
        #!/bin/sh

        set -eu

        usage() {
          echo "Usage: matugen-wallpaper IMAGE" >&2
        }

        if [ "$#" -ne 1 ]; then
          usage
          exit 2
        fi

        case "$1" in
          -h|--help)
            usage
            exit 0
            ;;
        esac

        input=$1
        case "$input" in
          "~/"*) input="$HOME/''${input#~/}" ;;
          /*) ;;
          *) input="$PWD/$input" ;;
        esac

        image_dir=$(/usr/bin/dirname "$input")
        image_name=$(/usr/bin/basename "$input")
        if ! normalized_dir=$(CDPATH= cd -P "$image_dir" 2>/dev/null && /bin/pwd); then
          echo "matugen-wallpaper: directory not found: $image_dir" >&2
          exit 1
        fi
        image_dir=$normalized_dir
        image="$image_dir/$image_name"

        if [ ! -f "$image" ]; then
          echo "matugen-wallpaper: image not found: $image" >&2
          exit 1
        fi

        /bin/mkdir -p "$HOME/.cache/matugen"
        ${pkgs.matugen}/bin/matugen image \
          --mode dark \
          --type scheme-tonal-spot \
          --contrast 0 \
          --source-color-index 0 \
          -- "$image"
        /usr/bin/printf '%s\n' "$image" > "$HOME/.cache/matugen/current_wallpaper"
        /usr/bin/printf '✓ Wallpaper: %s\n' "$image"
      '';
    };

    # Matugen follows the native macOS application-support directory instead
    # of XDG_CONFIG_HOME when no explicit --config path is provided.
    home.file."Library/Application Support/com.InioX.matugen/config.toml".source = darwinConfig;
    xdg.configFile."matugen/templates".source = matugenSource + /templates;
    xdg.configFile."matugen/set-wallpaper" = {
      executable = true;
      text = ''
        #!/bin/sh
        /usr/bin/osascript - "$1" <<'APPLESCRIPT'
        on run argv
          set wallpaperPath to POSIX file (item 1 of argv)
          tell application "System Events"
            repeat with desktopItem in desktops
              set picture of desktopItem to wallpaperPath
            end repeat
          end tell
        end run
        APPLESCRIPT
      '';
    };
    xdg.configFile."btop/themes/matugen.theme" = {
      source = cacheLink "btop.theme";
      force = true;
    };
    xdg.configFile."yazi/theme.toml" = {
      source = cacheLink "yazi-theme.toml";
      force = true;
    };
    xdg.configFile."nvim/lua/matugen.lua" = {
      source = cacheLink "nvim-matugen.lua";
      force = true;
    };

    home.activation.ensureMatugenColors = ensureMatugenColors {
      generationId = "${matugenSource}:${nvimTemplate}:${darwinConfig}:darwin";
      # Matugen's macOS wallpaper backend invokes system tools by name, while
      # Home Manager activation runs with a Nix-only PATH.
      hookPath = "${lib.makeBinPath [
        pkgs.bash
        pkgs.coreutils
        pkgs.matugen
      ]}:/usr/bin:/bin";
      requiredOutputs = sharedOutputs ++ [
        "${home}/.cache/matugen/squirrel-colors.yaml"
        "${home}/Library/Rime/matugen.yaml"
      ];
    };
  };
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.isDarwin (mkDarwinConfig { }))
  (lib.mkIf pkgs.stdenv.isLinux (mkLinuxConfig { }))
]
