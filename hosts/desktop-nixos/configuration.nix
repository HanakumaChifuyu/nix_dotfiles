# Host-specific configuration for desktop-nixos
# Extends the base configuration.nix with host-specific overrides

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../configuration.nix
    ../../modules/desktop.nix
    ../../hardware-configuration.nix
  ];

  # Host-specific settings override the base configuration

  # Zen kernel: optimized for desktop responsiveness and low latency
  boot.kernelPackages = pkgs.linuxPackages_zen;

  time.timeZone = "Asia/Shanghai";
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

  };
  networking.hostName = "desktop_nixos";

  # Hibernate can resume from the dedicated swap partition generated in
  # ../../hardware-configuration.nix.
  boot.resumeDevice = "/dev/disk/by-label/swap";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  services.upower.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      PCIE_ASPM_ON_BAT = "powersupersave";
      AMDGPU_ABM_LEVEL_ON_BAT = 3;
      START_CHARGE_THRESH_BAT0 = 98;
      STOP_CHARGE_THRESH_BAT0 = 99;
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    libcanberra-gtk3
    libnotify
    sound-theme-freedesktop
    wireplumber
  ];
}
