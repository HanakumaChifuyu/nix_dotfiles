{
  config,
  lib,
  pkgs,
  ...
}:

{

  sops.secrets.my-password.neededForUsers = true;
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.tohno = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "docker"
      "adbusers"
      "podman"
    ];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."tohno/passwd".path;
  };
}
