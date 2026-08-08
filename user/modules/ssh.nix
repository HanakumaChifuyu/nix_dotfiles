{ lib, ... }:

let
  # Helper to expand host configs (supports simple IP strings or full attribute sets with defaults)
  mkHostGroup =
    defaults: hosts:
    lib.mapAttrs (
      name: cfg: if builtins.isString cfg then defaults // { Hostname = cfg; } else defaults // cfg
    ) hosts;

  # Load host groups from modular host files
  evoxtHosts = mkHostGroup {
    User = "root";
    Port = 22;
  } (import ./ssh/hosts/evoxt.nix);
  workHosts = import ./ssh/hosts/work.nix;
  vpsHosts = import ./ssh/hosts/vps.nix;
  lanHosts = import ./ssh/hosts/lan.nix;
  gitHosts = import ./ssh/hosts/git.nix;

  # Global & Provider Wildcard Settings
  defaultSettings = {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "yes";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "1h";
    };
  };
in
{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = defaultSettings // evoxtHosts // workHosts // vpsHosts // lanHosts // gitHosts;
  };
}
