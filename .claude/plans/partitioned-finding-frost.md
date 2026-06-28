# Refactor sing-box.nix: JSON string → Native Nix attrsets

## Context

The current `modules/sing-box.nix` (631 lines) embeds a massive JSON string in `sops.template."sing-box.json".content`, then uses `builtins.fromJSON` to parse it back into a Nix attrset for `services.sing-box.settings`. This is hard to maintain, has significant duplication (the 30-element rule_set tag list appears 3 times, rule_set URL blocks repeat 30 times), and contains a typo bug on line 190 (`pasawd` instead of `password`).

The NixOS sing-box module natively supports `_secret` values — any attrset `{ _secret = "/path/to/file"; }` gets replaced with the file contents at service startup via `genJqSecretsReplacementSnippet`. This eliminates the need for `sops.template` altogether.

## Plan

### 1. Keep sops secrets, remove sops.template

- Keep `sops.secrets."hysteria2/ip"`, `sops.secrets."hysteria2/password"`, `sops.secrets."hysteria2/obs/password"` declarations
- Remove `sops.template."sing-box.json"` entirely (and `builtins.fromJSON` on it)
- Bind secret paths in a `let` block:
  ```nix
  hy2-ip = config.sops.secrets."hysteria2/ip".path;
  hy2-password = config.sops.secrets."hysteria2/password".path;
  hy2-obs-password = config.sops.secrets."hysteria2/obs/password".path;
  ```

### 2. Extract repeated data into let bindings

- **`cn-rule-set-tags`**: The list of 30 CN service names — used in `dns.rules[1].rule_set`, `route.rule_set[]` generation, and `route.rules.rule_set`
- **`mkRuleSet`**: A function `tag: { ... }` that generates a rule_set definition block from a tag name, eliminating 30 near-identical blocks
- **`cn-domains-dns`**: The DNS-version Chinese/SaaS domain list (lines 82–137)
- **`cn-domains-route`**: The route-version domain list (includes everything in `cn-domains-dns` plus additional domains from lines 496–603)

### 3. Convert to native Nix attrsets in services.sing-box.settings

All JSON keys become unquoted Nix attrset keys. Examples:
```nix
# JSON: {"log": {"level": "error", "timestamp": true}}
# Nix:
log = { level = "error"; timestamp = true; };

# JSON: [{"type": "mixed", "tag": "mixed-in", "listen": "127.0.0.1", "listen_port": 7890}]
# Nix:
[ { type = "mixed"; tag = "mixed-in"; listen = "127.0.0.1"; listen_port = 7890; } ]
```

### 4. Use _secret for hysteria2 credentials

```nix
{
  type = "hysteria2";
  tag = "proxy";
  server = { _secret = hy2-ip; };
  server_port = 8843;
  password = { _secret = hy2-password; };
  obfs = {
    type = "salamander";
    password = { _secret = hy2-obs-password; };
  };
  tls = { enabled = true; server_name = "cdn-test.microsoft.com"; insecure = true; };
}
```

### 5. Fix the typo

Line 190: `${config.sops.placeholder."hysteria2/obs/pasawd"}` → `config.sops.secrets."hysteria2/obs/password".path`

## Files to modify

- `modules/sing-box.nix` — complete rewrite (no other files affected)

## Verification

1. `nix flake check` — validates Nix syntax and structure
2. `sudo nixos-rebuild dry-build` — confirms the config builds successfully
3. Check that all domain lists in the refactored version match the originals exactly
4. Verify secret paths resolve correctly (`_secret` mechanism uses `config.sops.secrets.*.path`, which always resolves)
