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
    ../../hardware-configuration.nix
  ];

  # Host-specific settings override the base configuration
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "gpu_nixos";

  # ============================================================================
  # NVIDIA GPU Configuration
  # ============================================================================

  # Enable OpenGL / Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA driver (Wayland-compatible via modesetting)
  services.xserver.videoDrivers = [ "nvidia" ];
  # Enable dynamic CDI configuration for Nvidia devices by running nvidia-container-toolkit on boot.
  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {
    # Modesetting required for Wayland
    modesetting.enable = true;
    # Power management
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # RTX 50 series requires the open-source kernel module.
    open = true;

    # Prevent suspend issues
    nvidiaPersistenced = true;

    # RTX 50 series support lands first in the latest driver branch.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # CUDA support for ML/compute workloads
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];

  # Environment variables for NVIDIA + Wayland
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs.nix-ld = {
    enable = true;
    libraries = [
      pkgs.linuxPackages.nvidia_x11
      pkgs.cudaPackages.cudatoolkit
    ];
  };

  # ============================================================================
  # Gaming Configuration
  # ============================================================================
  programs.steam = {
    enable = true;
    # 开放串流端口
    remotePlay.openFirewall = true;
    # 开放局域网联机端口
    dedicatedServer.openFirewall = true;
    # 启用 gamescope 支持（在 Wayland 下玩游戏很有用）
    gamescopeSession.enable = true;
  };
}
