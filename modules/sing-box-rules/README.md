# sing-box rule snapshot

These binary rule sets are vendored from
https://github.com/senshinya/singbox_ruleset at revision
`abe7eb846470d4656964755eacfcc8093074237b`.

Upstream path: `rule/<tag>/<tag>.srs`.
The revision and original SHA-256 hashes are recorded in `../sing-box-rules.nix`.
All files were checked against those hashes when vendored; no rule contents were changed.

Keeping the snapshot in the repository lets a new NAS build its proxy configuration
without first needing a working proxy to fetch the rules. This snapshot is shared
by the NixOS and macOS settings. Include the `.srs` files when copying the repository.

When updating, replace the files, revision and hashes together, and verify the hashes
before deploying.
