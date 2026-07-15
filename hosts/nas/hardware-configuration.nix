# Placeholder hardware configuration for the NAS.
# Replace this with the output from nixos-generate-config on the target machine.

{ lib, ... }:

{
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = lib.mkDefault [ ];
}
