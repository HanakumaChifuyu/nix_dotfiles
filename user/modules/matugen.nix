{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = toString config.home.homeDirectory;
  wallpapers = ../Wallpapers;
  cacheLink = path: config.lib.file.mkOutOfStoreSymlink (home + "/.cache/matugen/" + path);
  walLink = path: config.lib.file.mkOutOfStoreSymlink (home + "/.cache/wal/" + path);
  matugenHookPath = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.matugen
    pkgs.mako
    pkgs.procps
    # pkgs.swaynotificationcenter  # swaync replaced by mako
    pkgs.awww
  ];
  requiredOutputs = [
    "${home}/.cache/wal/colors-waybar.css"
    "${home}/.cache/wal/colors.json"
    "${home}/.cache/matugen/hypr-vars.conf"
    "${home}/.cache/matugen/hyprland-bindings.conf"
    "${home}/.cache/matugen/hypr-vars.lua"
    # "${home}/.cache/matugen/swaync-style.css"  # swaync replaced by mako
    "${home}/.cache/matugen/fuzzel-colors.ini"
    "${home}/.cache/matugen/foot-colors.ini"
    "${home}/.cache/matugen/kitty-colors.conf"
    "${home}/.cache/matugen/mako-colors"
    "${home}/.cache/matugen/btop.theme"
    "${home}/.cache/matugen/yazi-theme.toml"
    "${home}/.cache/matugen/nvim-matugen.lua"
  ];
in
{
  xdg.configFile."matugen" = {
    source = ../dotfiles/.config/matugen;
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

  home.activation.cleanMatugenCache = lib.hm.dag.entryBefore [ "ensureMatugenColors" ] ''
    echo "Cleaning matugen cache..."
    rm -rf "${home}/.cache/matugen" "${home}/.cache/wal"
  '';

  home.activation.ensureMatugenColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    needs_generation=0
    for output in ${lib.escapeShellArgs requiredOutputs}; do
      if [[ ! -s "$output" ]]; then
        needs_generation=1
        break
      fi
    done

    if [[ "$needs_generation" -eq 1 ]]; then
      mkdir -p "${home}/.cache/matugen" "${home}/.cache/wal"

      wallpaper=""
      for candidate in "${wallpapers}"/*; do
        case "''${candidate,,}" in
          *.jpg|*.jpeg|*.png|*.webp)
            wallpaper="$candidate"
            break
            ;;
        esac
      done

      if [[ -n "$wallpaper" ]]; then
        echo "Generating initial matugen colors from $wallpaper"
        SHELL="${pkgs.bash}/bin/bash" \
        PATH="${matugenHookPath}:$PATH" \
        MATUGEN_DEFER_HYPR_RELOAD=1 \
          ${pkgs.matugen}/bin/matugen image "$wallpaper"  --mode dark --type scheme-tonal-spot --contrast 0 --source-color-index 0
      else
        echo "No wallpaper found in ${wallpapers}; skipping initial matugen color generation"
      fi
    fi
  '';

  # Home Manager starts mako through D-Bus activation. Reload that single
  # instance instead of starting mako.service, which would compete for the
  # org.freedesktop.Notifications bus name and leave a failed unit behind.
  home.activation.reloadMako = lib.hm.dag.entryAfter [ "ensureMatugenColors" ] ''
    ${pkgs.systemd}/bin/systemctl --user reset-failed mako.service >/dev/null 2>&1 || true
    ${pkgs.mako}/bin/makoctl reload >/dev/null 2>&1 || true
  '';
}
