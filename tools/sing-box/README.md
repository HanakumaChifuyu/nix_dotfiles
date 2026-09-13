# Linux sing-box 测试

Mac 配置和测试见 [mac.md](mac.md)。

配置入口是 `modules/sing-box.nix`，适用于 `desktop_nixos` 和 `gpu_nixos`。
Fish 的全局代理变量、本地 7890 端口和 Hysteria2 节点参数保持原样。

本次调整：

- 普通 TCP/UDP 53 查询先进入 DNS 劫持，再处理目标 IP 和域名直连规则；
  `100.100.100.100:53` 保留 MagicDNS 直连例外。
- DNS 和连接分流共享显式直连域名；移除 URL 路径和重复项。
- 移除 `mirror` 关键字直连，以及 RubyGems、Rust、Homebrew 等上游的直连例外。
  这些上游默认走代理，明确列出的国内镜像继续直连。
- 保留 Linux `auto_redirect` 的出口标记机制和原有 Tailscale 路由排除。
- 30 份规则集固定上游提交与 SHA-256，在 Nix 构建时下载，运行时读取 Nix store。
  其中 `Blizzard` 覆盖战网、暴雪游戏域名和游戏服务器 IP，按现有策略使用国内 DNS 并直连。
  不再每天自动跟随上游 `main`；更新规则需要同时修改
  `modules/sing-box-rules.nix` 中的 revision 和 hashes，然后重新构建。
  构建下载先尝试 GitHub，再尝试同一提交的 jsDelivr URL。

## 在原机器临时启用

在仓库目录执行。以下用 Bash 保存当前系统路径，便于在同一终端回退；
GPU 主机把 `desktop_nixos` 替换为 `gpu_nixos`。

```bash
bash
singbox_previous_system=$(readlink -f /run/current-system)
sudo nixos-rebuild test --flake .#desktop_nixos
systemctl is-active sing-box
sudo sing-box check -c /run/sing-box/config.json
sudo journalctl -u sing-box -n 80 --no-pager
```

`test` 立即启用配置，但不改变默认启动项。构建时需要能下载尚未缓存的规则集。

```bash
dig @223.5.5.5 example.org A +short
dig @1.1.1.1 example.org A +short
dig +tcp @223.5.5.5 example.org A +short
dig @223.5.5.5 mirrors.tuna.tsinghua.edu.cn A +short
```

前三项预期返回 `198.18.0.0/15` 内的 FakeIP，镜像域名应返回实际地址。
再检查日常网页、包下载、Steam 下载和实际 Tailscale 主机名是否可用。

如需回退，在刚才的 Bash 终端执行：

```bash
sudo "$singbox_previous_system/bin/switch-to-configuration" test
```

确认正常后，用相同主机名执行 `sudo nixos-rebuild switch --flake .#desktop_nixos`。

## 本地验证范围

修改时使用仓库锁定的 sing-box 1.13.13：两个 Linux 主机的 sing-box 配置求值通过；
30 份规则集的 Nix 下载、哈希校验和二进制解码通过。
在 macOS 上去除 Linux TUN 入站、使用占位凭据后，`sing-box check` 通过；
用本地 DNS 和 SOCKS 测试端点验证了 13 项 DNS/路由行为。
这些检查未启用系统 TUN，也未连接实际 Hysteria2 节点，不能替代原机器的网络测试。
