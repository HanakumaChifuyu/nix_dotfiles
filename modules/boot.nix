{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Boot loader configuration
  # --- UEFI (物理机/UEFI虚拟机) ---
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # --- BIOS/Legacy (当前虚拟机) ---
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/vda";
  #
}
