{
  config,
  lib,
  pkgs,
  ...
}:
let
  base = import ../../modules/sing-box-settings.nix {
    inherit pkgs;
    # Runtime values replace these non-secret placeholders, never at Nix evaluation.
    credentials = {
      server = "192.0.2.1";
      password = "runtime-placeholder";
      obfsPassword = "runtime-placeholder";
      serverName = "example.invalid";
    };
    tun = {
      type = "tun";
      tag = "tun-in";
      # Let Darwin allocate a free utun device. Linux auto_redirect is unavailable.
      address = [
        "172.19.0.1/30"
        "fdfe:dcba:9876::1/126"
      ];
      mtu = 1350;
      stack = "system";
      auto_route = true;
      route_exclude_address = [
        "10.0.0.0/8"
        # Exclude private LANs except the TUN subnet itself: its peer/DNS
        # address must remain reachable through utun, including TCP replies.
        "172.24.0.0/13"
        "172.20.0.0/14"
        "172.16.0.0/15"
        "172.18.0.0/16"
        "172.19.128.0/17"
        "172.19.64.0/18"
        "172.19.32.0/19"
        "172.19.16.0/20"
        "172.19.8.0/21"
        "172.19.4.0/22"
        "172.19.2.0/23"
        "172.19.1.0/24"
        "172.19.0.128/25"
        "172.19.0.64/26"
        "172.19.0.32/27"
        "172.19.0.16/28"
        "172.19.0.8/29"
        "172.19.0.4/30"
        "192.168.0.0/16"
        "100.64.0.0/10"
        "fd7a:115c:a1e0::/48"
      ];
    };
  };
  # macOS watches each rule file's parent directory. Give every rule a small
  # directory instead of watching all of /nix/store (which exhausts file handles).
  ruleFiles = pkgs.runCommand "sing-box-mac-rule-files" { } (
    lib.concatMapStringsSep "\n" (rule: ''
      mkdir -p "$out/${rule.tag}"
      cp ${lib.escapeShellArg rule.path} "$out/${rule.tag}/rules.srs"
    '') base.route.rule_set
  );
  settings = base // {
    dns = base.dns // {
      servers = map (
        server: if server.tag == "tailscale" then server // { detour = "local"; } else server
      ) base.dns.servers;
    };
    outbounds = base.outbounds ++ [
      {
        type = "direct";
        tag = "local";
        # Wildcard source binding bypasses auto_detect_interface in sing-box
        # 1.13, allowing excluded LAN/Tailscale routes to use their own interface.
        inet4_bind_address = "0.0.0.0";
        inet6_bind_address = "::";
      }
    ];
    route = base.route // {
      auto_detect_interface = true;
      rule_set = map (rule: rule // { path = "${ruleFiles}/${rule.tag}/rules.srs"; }) base.route.rule_set;
      rules = [
        {
          ip_cidr = [ "fd7a:115c:a1e0::/48" ];
          outbound = "local";
        }
      ]
      ++ map (
        rule:
        if
          (rule.ip_is_private or false)
          || lib.elem "100.64.0.0/10" (rule.ip_cidr or [ ])
          || lib.elem "100.100.100.100/32" (rule.ip_cidr or [ ])
          || lib.elem "ts.net" (rule.domain_suffix or [ ])
        then
          rule // { outbound = "local"; }
        else
          rule
      ) base.route.rules;
    };
  };
  template = (pkgs.formats.json { }).generate "sing-box-mac-template.json" settings;
  runner = pkgs.writeShellScriptBin "sing-box-mac" ''
    exec ${pkgs.python3}/bin/python3 ${../../tools/sing-box/mac-service.py} \
      --template ${template} \
      --secrets ${../../secrets/keys.yaml} \
      --identity ${lib.escapeShellArg "${config.users.users.tohno.home}/.config/sops/age/keys.txt"} \
      --sing-box ${lib.getExe pkgs.sing-box} \
      --sops ${lib.getExe pkgs.sops} \
      --curl ${lib.getExe pkgs.curl} "$@"
  '';
in
{
  environment.systemPackages = [
    pkgs.sing-box
    runner
  ];
  system.build.singBoxMac = runner;

  launchd.daemons.sing-box = {
    serviceConfig = {
      UserName = "root";
      ProgramArguments = [
        "${runner}/bin/sing-box-mac"
        "run"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 15;
      ExitTimeOut = 30;
      Umask = 63; # 0077: runtime files and logs are private to root.
      StandardOutPath = "/var/log/sing-box.log";
      StandardErrorPath = "/var/log/sing-box.log";
    };
  };
}
