# Mac sing-box：age 密钥准备

本文记录密钥准备流程。Mac sing-box 的启动配置和网络测试见 [mac.md](mac.md)。

Mac 私钥保存在 `~/.config/sops/age/keys.txt`，权限为 `600`，所在目录权限为 `700`。
公钥已登记到仓库 `.sops.yaml` 的 `macbook` recipient，原 Linux recipients 保留。
私钥应自行安全备份，不要提交到 Git，也不要拷贝到另一台机器来更新密文。

`user/hosts/macbook/home.nix` 已加入 `age` 和 `sops` 工具。
尚未应用 Home Manager 时，可以在仓库根目录临时使用锁定版本的工具：

```bash
nix shell --inputs-from . nixpkgs#age nixpkgs#sops -c bash tools/sing-box/check-mac-age.sh
```

测试脚本检查私钥权限、age 加解密，以及使用本仓库 `.sops.yaml` 规则生成的
SOPS 测试密文能否由 Mac 解密。临时文件只包含测试字符串，退出时自动清理。
脚本不会重新生成或覆盖私钥，也不会打印真实 secrets。

## 给现有密文授权

只修改 `.sops.yaml` 不会使现有 `secrets/keys.yaml` 自动获得新的 recipient。
在已能解密该文件的原 Linux 机器上，先取得包含 Mac 公钥的本次仓库改动，再执行：

```bash
bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
sops updatekeys --yes secrets/keys.yaml
sops --decrypt secrets/keys.yaml >/dev/null
git add secrets/keys.yaml
git commit -m "chore(sops): authorize MacBook age identity"
git push
```

这里的 `SOPS_AGE_KEY_FILE` 指向原 Linux 机器已有的 identity，不是 Mac 新私钥。
`updatekeys` 为已有数据密钥添加 Mac recipient，不修改节点密码，也保留 Linux 的访问权。
若该 Linux identity 未授权，需改用那台机器已有的可解密 identity。

Mac 拉取更新后的密文，再运行严格检查：

```bash
git pull --ff-only
nix shell --inputs-from . nixpkgs#age nixpkgs#sops -c bash tools/sing-box/check-mac-age.sh --require-secrets
```

普通检查在现有密文尚未授权时输出 `PENDING`，但允许已完成的密钥自检成功退出。
严格检查此时退出码为 `2`；只有现有密文也能解密才返回成功。
严格检查通过后，继续接入 Mac sing-box 的运行时配置生成和启动服务。
