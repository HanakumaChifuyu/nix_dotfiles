{ config, lib, pkgs, ... }:

let
  cfg = config.services.remoteDesktop;
  apps = pkgs.writeText "remote-desktop-apps.json" (builtins.toJSON {
    apps = [ { name = "Desktop"; } ];
  });
  sunshineConfig = pkgs.writeText "remote-desktop-sunshine.conf" ''
    sunshine_name = NAS Remote Desktop
    capture = wlr
    encoder = nvenc
    file_apps = ${apps}
  '';
  session = pkgs.writeShellScript "remote-desktop-session" ''
    set -eu
    ${pkgs.wlr-randr}/bin/wlr-randr --output HEADLESS-1 --custom-mode 1920x1080@60Hz
    ${pkgs.foot}/bin/foot &
    exec ${config.services.sunshine.package}/bin/sunshine ${sunshineConfig}
  '';
  start = pkgs.writeShellScript "remote-desktop-start" ''
    set -eu
    # Keep Wayland/XWayland sockets separate from other sessions of this user.
    export XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR/labwc-remote"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
    unset DISPLAY WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS
    export WLR_BACKENDS=headless,libinput
    export WLR_HEADLESS_OUTPUTS=1
    export WLR_RENDERER=gles2
    export WLR_LIBINPUT_NO_DEVICES=1
    export LIBSEAT_BACKEND=seatd
    export LABWC_UPDATE_ACTIVATION_ENV=0
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=labwc:wlroots
    exec ${pkgs.dbus}/bin/dbus-run-session -- \
      ${pkgs.labwc}/bin/labwc -d -C ${./config} -S ${session}
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.labwc.enable = true;
    environment.systemPackages = with pkgs; [ foot wlr-randr vulkan-tools ];
    fonts.packages = [ pkgs.dejavu_fonts ];

    systemd.user.services.labwc-remote = {
      description = "Headless labwc with Sunshine (start manually)";
      unitConfig.ConditionUser = cfg.user;
      # No wantedBy: only start when requested, not at login or boot.
      serviceConfig = {
        ExecStart = start;
        Restart = "no";
        KillMode = "control-group";
        TimeoutStopSec = 15;
        UMask = "0077";
      };
      path = [ pkgs.foot pkgs.vulkan-tools pkgs.xwayland ];
    };
  };
}
