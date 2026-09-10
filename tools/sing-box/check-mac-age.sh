#!/usr/bin/env bash
# Checks the Mac identity and SOPS recipient rule without printing any secrets.
# --require-secrets also requires the existing repository secrets to decrypt.
set -euo pipefail
umask 077

require_secrets=false
case "${1:-}" in
  "") ;;
  --require-secrets) require_secrets=true ;;
  *) echo "Usage: bash $0 [--require-secrets]" >&2; exit 1 ;;
esac

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
key_file=${MAC_AGE_KEY_FILE:-"$HOME/.config/sops/age/keys.txt"}
for tool in age age-keygen sops; do
  command -v "$tool" >/dev/null || {
    echo "Missing $tool; run this script inside the Nix shell documented in mac-age.md." >&2
    exit 1
  }
done

[[ -f "$key_file" && ! -L "$key_file" ]] || {
  echo "Missing regular identity file: $key_file" >&2
  exit 1
}
if [[ $(uname -s) == Darwin ]]; then
  key_mode=$(stat -f '%Lp' "$key_file")
  key_owner=$(stat -f '%u' "$key_file")
  dir_mode=$(stat -f '%Lp' "$(dirname "$key_file")")
else
  key_mode=$(stat -c '%a' "$key_file")
  key_owner=$(stat -c '%u' "$key_file")
  dir_mode=$(stat -c '%a' "$(dirname "$key_file")")
fi
[[ "$key_mode" == 600 && "$dir_mode" == 700 && "$key_owner" == "$(id -u)" ]] || {
  echo "Identity must be owned by the current user, mode 600, in a mode 700 directory." >&2
  exit 1
}
echo "PASS: identity permissions and owner"

public_key=$(age-keygen -y "$key_file")
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/sing-box-age-test.XXXXXX")
trap 'rm -rf -- "$test_dir"' EXIT
printf '{"test":"sing-box Mac age self-test"}\n' > "$test_dir/plain.json"
age -r "$public_key" -o "$test_dir/test.age" "$test_dir/plain.json"
age -d -i "$key_file" "$test_dir/test.age" | cmp -s "$test_dir/plain.json" -
echo "PASS: age encrypt/decrypt round trip"

cd "$repo_dir"
# Match the real creation rule without writing a test file into secrets/.
sops --config "$repo_dir/.sops.yaml" --filename-override secrets/mac-age-self-test.json \
  --input-type json --output-type json --encrypt "$test_dir/plain.json" > "$test_dir/test.enc.json"
# Extract just the synthetic test value; real repository plaintext is never printed.
test_value=$(SOPS_AGE_KEY_FILE="$key_file" sops --decrypt --extract '["test"]' "$test_dir/test.enc.json")
[[ "$test_value" == 'sing-box Mac age self-test' ]]
echo "PASS: repository SOPS creation rule includes the Mac identity"

if ! grep -Fq -- "recipient: $public_key" secrets/keys.yaml; then
  echo "PENDING: secrets/keys.yaml needs 'sops updatekeys' on an already-authorized machine."
  if "$require_secrets"; then exit 2; fi
  exit 0
fi
SOPS_AGE_KEY_FILE="$key_file" sops --decrypt secrets/keys.yaml >/dev/null
echo "PASS: existing repository secrets decrypt successfully (plaintext discarded)"
