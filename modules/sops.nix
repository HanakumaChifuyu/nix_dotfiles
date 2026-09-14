{
  config,
  lib,
  pkgs,
  ...
}:
let
  sopsUser = "tohno";
  sopsUserHome = "/home/tohno";
  sopsUserAgeKeyFile = "${sopsUserHome}/.config/sops/age/keys.txt";
in
{

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../secrets/keys.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # All secrets use age; do not try importing an RSA host key for GPG.
  sops.gnupg.sshKeyPaths = [ ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  system.activationScripts.generateUserSopsAgeKey = {
    deps = [ "users" ];
    text = ''
      # Isolate error handling and cleanup from the shared activation shell.
      (
      set -e
      host_key=/etc/ssh/ssh_host_ed25519_key
      user_age_key=${sopsUserAgeKeyFile}
      user_age_dir=$(${pkgs.coreutils}/bin/dirname "$user_age_key")

      if [ -f "$host_key" ]; then
        ${pkgs.coreutils}/bin/install -d -m 700 -o ${sopsUser} -g users "$user_age_dir"
        # nixos-install can pass a TMPDIR that does not exist inside the chroot.
        # An absolute template avoids TMPDIR and allows an atomic final rename.
        tmp_key=$(${pkgs.coreutils}/bin/mktemp "$user_age_dir/.keys.txt.XXXXXXXXXX")
        trap '${pkgs.coreutils}/bin/rm -f -- "$tmp_key"' EXIT
        ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$host_key" -o "$tmp_key"
        ${pkgs.coreutils}/bin/chmod 600 "$tmp_key"
        ${pkgs.coreutils}/bin/chown ${sopsUser}:users "$tmp_key"
        ${pkgs.coreutils}/bin/mv -f -- "$tmp_key" "$user_age_key"
      else
        echo "[sops] WARNING: $host_key not found; cannot derive user age key for Home Manager." >&2
      fi
      )
    '';
  };

}
