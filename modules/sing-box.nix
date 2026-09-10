{ config, pkgs, ... }:
let
  node = "sing_box/jp_osaka/hysteria2";
  secret = name: { _secret = config.sops.secrets."${node}/${name}".path; };
in
{
  sops.secrets."${node}/server_ip" = { };
  sops.secrets."${node}/passwd" = { };
  sops.secrets."${node}/obfs/password" = { };
  sops.secrets."${node}/tls/server_name" = { };

  services.sing-box = {
    enable = true;
    settings = import ./sing-box-settings.nix {
      inherit pkgs;
      credentials = {
        server = secret "server_ip";
        password = secret "passwd";
        obfsPassword = secret "obfs/password";
        serverName = secret "tls/server_name";
      };
      tun = {
        type = "tun";
        tag = "tun-in";
        interface_name = "tun0";
        address = [
          "172.19.0.1/30"
          "fdfe:dcba:9876::1/126"
        ];
        mtu = 1350;
        stack = "system";
        auto_route = true;
        strict_route = true;
        # Linux auto_redirect marks sing-box's own outbound sockets to bypass
        # the TUN. Avoid binding all direct traffic to the physical interface,
        # which would also bind connections intended for Tailscale.
        auto_redirect = true;
        route_exclude_address = [ "100.64.0.0/10" ];
      };
    };
  };
}
