{ ... }:

{
  networking.hostName = "vps-test";

  # Test-only account. Do not copy its password to a real VPS configuration.
  users.users.vps = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "vps";
  };
  security.sudo.wheelNeedsPassword = false;

  virtualisation.vmVariant = {
    virtualisation = {
      graphics = false;
      memorySize = 2048;
      cores = 2;
    };
  };
}
