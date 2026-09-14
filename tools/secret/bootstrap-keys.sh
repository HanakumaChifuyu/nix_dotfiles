#!/usr/bin/env bash
# Prepare a new machine's SSH host key locally and register its age recipient.
set -euo pipefail
umask 077

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output_dir=
name=nas-5060ti-16G
sops_file="$script_dir/../../.sops.yaml"

usage() {
  cat <<'EOF'
用法: bash tools/secret/bootstrap-keys.sh [--output-dir PATH] [--name NAME] [--sops-file PATH]

在现有电脑上运行，无需 sudo；生成的 SSH 密钥对随后复制到新机器。

  --output-dir PATH 本机密钥输出目录，默认 ~/.local/share/nix-dotfiles/host-keys/NAME
  --name NAME       .sops.yaml 中的密钥名称，默认 nas-5060ti-16G
  --sops-file PATH  默认使用本仓库的 .sops.yaml
  -h, --help        显示帮助

依赖: OpenSSH (ssh-keygen)、age、ssh-to-age，以及系统自带的 awk 等工具。
复用已有 SSH host key，不覆盖同名但公钥不同的 SOPS recipient。
EOF
}
die() { printf '错误: %s\n' "$*" >&2; exit 1; }

while (($#)); do
  case "$1" in
    --output-dir|--name|--sops-file)
      (($# >= 2)) && [[ -n "$2" ]] || die "$1 缺少参数"
      case "$1" in
        --output-dir) output_dir=$2 ;;
        --name) name=$2 ;;
        --sops-file) sops_file=$2 ;;
      esac
      shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1（使用 --help 查看用法）" ;;
  esac
done

[[ "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]] || die '密钥名称只能包含字母、数字、下划线和连字符，且不能以数字开头'
output_dir=${output_dir:-"$HOME/.local/share/nix-dotfiles/host-keys/$name"}
[[ -f "$sops_file" && ! -L "$sops_file" ]] || die "配置不存在或是符号链接: $sops_file"

missing=0
for tool in ssh-keygen age ssh-to-age; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf '缺少依赖: %s\n' "$tool" >&2
    missing=1
  fi
done
if ((missing)); then
  printf '%s\n' '可先运行: nix shell nixpkgs#openssh nixpkgs#age nixpkgs#ssh-to-age' >&2
  exit 1
fi

work_dir=$(mktemp -d)
config_tmp=
cleanup() {
  rm -rf -- "$work_dir"
  if [[ -n "$config_tmp" ]]; then rm -f -- "$config_tmp"; fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

key_dir=$output_dir
host_key="$key_dir/ssh_host_ed25519_key"
mkdir -p -- "$key_dir"
chmod 700 "$key_dir"
[[ ! -L "$host_key" ]] || die "拒绝使用符号链接私钥: $host_key"
[[ ! -L "$host_key.pub" ]] || die "拒绝使用符号链接公钥: $host_key.pub"
if [[ -e "$host_key" ]]; then
  [[ -f "$host_key" ]] || die "私钥路径不是普通文件: $host_key"
  printf '复用 SSH host key: %s\n' "$host_key"
else
  [[ ! -e "$host_key.pub" && ! -L "$host_key.pub" ]] || die "只存在 .pub 文件，请先检查: $host_key.pub"
  ssh-keygen -q -t ed25519 -N '' -C "$name" -f "$host_key"
  printf '已生成 SSH host key: %s\n' "$host_key"
fi
chmod 600 "$host_key"
# Derive from the private key, never trust a potentially stale .pub file.
ssh-keygen -y -P '' -f "$host_key" > "$work_dir/host.pub"
[[ $(<"$work_dir/host.pub") == ssh-ed25519\ * ]] || die '已有 host key 不是 Ed25519 类型'
# Recreate a missing or stale public key so the exported pair always matches.
cat "$work_dir/host.pub" > "$host_key.pub"
chmod 644 "$host_key.pub"
recipient=$(ssh-to-age -i "$work_dir/host.pub")
[[ "$recipient" =~ ^age1[0-9a-z]+$ ]] || die 'ssh-to-age 未返回有效的 age 公钥'
ssh-to-age -private-key -i "$host_key" -o "$work_dir/identity"
printf 'bootstrap check\n' | age -r "$recipient" -o "$work_dir/check.age"
age -d -i "$work_dir/identity" "$work_dir/check.age" > "$work_dir/check.txt"
[[ $(<"$work_dir/check.txt") == 'bootstrap check' ]] || die 'age 加解密检查失败'

# Support the repository's YAML layout; refuse unexpected layouts.
config_tmp=$(mktemp "${sops_file}.tmp.XXXXXX")
if ! awk -v name="$name" -v recipient="$recipient" '
  $0 == "keys:" { keys++; in_keys=1 }
  $0 == "creation_rules:" { rules++; in_keys=0; rule_start=NR }
  in_keys && $1 == "-" && $2 == "&" name {
    anchors++
    if ($3 != recipient) bad=1
  }
  /^      - age:$/ { groups++; group_line=NR }
  $1 == "-" && $2 == "*" name {
    refs++
    if ($0 != "          - *" name || !group_line) bad=1
  }
  { lines[NR]=$0 }
  END {
    if (keys != 1 || rules != 1 || groups != 1 || anchors > 1 || refs > 1 || bad) {
      print "错误: .sops.yaml 结构不受支持，或同名 recipient 与当前密钥不同；配置未修改。" > "/dev/stderr"
      exit 1
    }
    for (i=1; i<=NR; i++) {
      if (i == rule_start && !anchors) print "  - &" name " " recipient
      print lines[i]
      if (i == group_line && !refs) print "          - *" name
    }
  }
' "$sops_file" > "$config_tmp"; then
  exit 1
fi

if cmp -s "$sops_file" "$config_tmp"; then
  printf '公钥已登记，无需修改 .sops.yaml。\n'
else
  # Keep the existing file permissions and ownership.
  cat "$config_tmp" > "$sops_file"
  printf '已更新: %s\n' "$sops_file"
fi
printf 'age 公钥: %s\n' "$recipient"
printf '待复制的 SSH 密钥对:\n  %s\n  %s.pub\n' "$host_key" "$host_key"
cat <<'EOF'

下一步：在当前电脑的仓库根目录执行（需要已有密钥的解密权限）：
  sops updatekeys --yes secrets/keys.yaml
将上面两个文件通过 scp 或 U 盘复制到新 NAS：
  安装环境：/mnt/etc/ssh/
  已安装系统：/etc/ssh/
在 NAS 上将私钥属主设为 root:root、权限设为 600，公钥权限设为 644。
同步更新后的 .sops.yaml 和 secrets/keys.yaml，再执行安装或部署。
仅修改 .sops.yaml 不会自动授权现有密文。请勿将 SSH 私钥提交到 Git。
EOF
