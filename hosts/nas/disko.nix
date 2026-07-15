# Declarative disk layout for the NAS system disk.
# Replace the device path before running disko; applying this destroys the target disk.

{ lib, ... }:

{
  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/REPLACE_ME_NAS_SYSTEM_DISK";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
