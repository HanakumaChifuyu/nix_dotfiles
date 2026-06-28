{
  config,
  lib,
  pkgs,
  ...
}:

let
  home = config.home.homeDirectory;
  homeManagerWithHyprlandReload = pkgs.writeShellScriptBin "home-manager" ''
    set -euo pipefail

    should_reload=0
    dry_run=0
    for arg in "$@"; do
      case "$arg" in
        switch)
          should_reload=1
          ;;
        --dry-run)
          dry_run=1
          ;;
      esac
    done

    ${pkgs.home-manager}/bin/home-manager "$@"

    if [[ "$should_reload" -eq 1 && "$dry_run" -eq 0 && -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
      echo "Reloading Hyprland after Home Manager switch"
      if ! hyprctl reload >/dev/null 2>&1; then
        echo "warning: failed to reload Hyprland after Home Manager switch" >&2
      fi
    fi
  '';
in
{
  home.packages = [ homeManagerWithHyprlandReload ];

  home.activation.removeStaleStoreLinks = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    remove_stale_store_link() {
      local path="$1"
      local target

      if [[ -L "$path" ]]; then
        target="$(readlink "$path")"
        if [[ "$target" == /nix/store/* ]]; then
          rm "$path"
          mkdir -p "$path"
        fi
      fi
    }

    remove_stale_store_file_link() {
      local path="$1"
      local target

      if [[ -L "$path" ]]; then
        target="$(readlink "$path")"
        if [[ "$target" == /nix/store/* ]]; then
          rm "$path"
        fi
      fi
    }

    remove_stale_store_link "${home}/.config/fish"
    remove_stale_store_link "${home}/.config/nvim"
    remove_stale_store_file_link "${home}/.config/nvim/lazy-lock.json"
    remove_stale_store_link "${home}/.config/waybar"
    remove_stale_store_link "${home}/.config/btop"
    remove_stale_store_link "${home}/.config/yazi"
    remove_stale_store_link "${home}/.config/fontconfig"
    remove_stale_store_link "${home}/.claude"
    remove_stale_store_link "${home}/.ssh"
  '';

  home.activation.stopUnmanagedSwaync = lib.hm.dag.entryBefore [ "reloadSystemd" ] ''
    if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet swaync.service 2>/dev/null; then
      for pid in $("${pkgs.procps}/bin/pgrep" -u "$(${pkgs.coreutils}/bin/id -u)" -x swaync || true); do
        kill "$pid" 2>/dev/null || true
      done
    fi
  '';
}
