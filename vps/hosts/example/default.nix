{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "replace-me";

  # Add your public key before first activation. Password SSH is disabled by
  # modules/ssh.nix, so deploying without a key would lock you out.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 REPLACE_WITH_YOUR_PUBLIC_KEY admin"
    ];
  };

  # Open only the ports this host actually serves.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
