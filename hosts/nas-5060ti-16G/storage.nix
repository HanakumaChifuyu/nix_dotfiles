{ pkgs, ... }:

{
  # Prepare the XFS filesystem and copy the existing home before booting this
  # configuration. See STORAGE.md. Formatting and migration are never automatic.
  fileSystems."/data" = {
    device = "/dev/disk/by-label/nas-data";
    fsType = "xfs";
    options = [ "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/home/tohno" = {
    device = "/data/home/tohno";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/data" ];
    # sops uses this user's age key during activation, before normal user login.
    neededForBoot = true;
  };

  environment.systemPackages = [ pkgs.xfsprogs pkgs.rsync ];
}
