{ config, pkgs, ... }:

let
  # Use the APFS volume UUID, not the container UUID or a changing disk number.
  volumeUUID = "86716007-5CB0-43DD-8FAD-21B953CB9AAE";
  mountPoint = "${config.users.users.tohno.home}/ssd-volume";

  # vifs locks fstab while this editor updates only this volume's entry.
  # In particular, preserve the Nix installer's /nix mount configuration.
  fstabEditor = pkgs.writeShellScript "external-ssd-fstab-editor" ''
    set -eu
    updated=$(/usr/bin/mktemp "$1.ssd.XXXXXX")
    trap '/bin/rm -f "$updated"' EXIT
    /usr/bin/awk \
      -v device="UUID=${volumeUUID}" \
      -v mountPoint="${mountPoint}" '
      $1 != device { print }
      END { print device " " mountPoint " apfs rw 0 0" }
    ' "$1" > "$updated"
    /bin/cat "$updated" > "$1"
  '';
in
{
  system.activationScripts.postActivation.text = ''
    echo "Configuring the external SSD mount point..."
    if [ ! -d "${mountPoint}" ]; then
      /usr/bin/install -d -o tohno -g staff -m 0755 "${mountPoint}"
    fi
    EDITOR=${fstabEditor} VISUAL=${fstabEditor} /usr/sbin/vifs
  '';
}
