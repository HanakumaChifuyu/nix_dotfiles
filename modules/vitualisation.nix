{ pkgs, ... }: {
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;

    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  environment.etc."containers/registries.conf.d/00-docker-mirror.conf".text = ''
    [[registry]]
    prefix = "docker.io"
    location = "docker.io"

    [[registry.mirror]]
    location = "docker.1ms.run"

    [[registry.mirror]]
    location = "proxy.vvvv.ee"  
  '';

}
