# NixOS / macOS Dotfiles

## 两阶段部署

系统配置和 Home Manager 配置在 flake 里是解耦的，需要分两步应用：

1. 先切换系统层：NixOS 使用 `nixos-rebuild`，macOS 使用 `darwin-rebuild`
2. 再切换用户层：统一使用 `home-manager switch`

这样系统服务、boot、用户账号、nix-darwin defaults 等机器级配置不会和用户 dotfiles、shell、编辑器配置绑在同一次激活里。

### NixOS

桌面机：

```sh
sudo nixos-rebuild switch --flake .#desktop_nixos
home-manager switch --flake .#tohno@desktop
```

GPU 主机：

```sh
sudo nixos-rebuild switch --flake .#gpu_nixos
home-manager switch --flake .#tohno@gpu
```

NAS：

```sh
sudo nixos-rebuild switch --flake .#nas
```

NAS 当前没有独立 Home Manager profile。

如果首次部署时还没有 `home-manager` 命令，可以用 `nix run` 临时调用 Home Manager。把 profile 换成对应机器的 `homeConfigurations` 名称：

```sh
nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager/release-26.05 -- switch --flake .#tohno@desktop
nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager/release-26.05 -- switch --flake .#tohno@gpu
```

### macOS / nix-darwin

当前 Mac 配置使用 Apple Silicon（`aarch64-darwin`），已有用户为 `tohno`。
系统入口是 `macbook`，Home Manager 入口是 `tohno@macbook`。

已完成首次部署后，在仓库根目录更新：

```sh
sudo darwin-rebuild switch --flake .#macbook
home-manager switch --flake '.#tohno@macbook'
```

系统层包含 sing-box 开机服务、Homebrew、字体与 macOS defaults；用户层包含
Fish、编辑器、Karabiner 规则、鼠须管和动态配色。Home Manager 以当前用户运行，不加 sudo。

首次安装、密钥准备、服务交接、日常维护和回滚见
[MacBook / nix-darwin 部署手册](hosts/macbook/README.md)。
代理相关的详细测试见 [Mac sing-box](tools/sing-box/mac.md)。

## 密钥管理

NixOS 使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理 secrets，系统和 Home Manager 以 SSH host key 作为 bootstrap 密钥。下面的流程仅适用于 NixOS；macOS 使用独立 age identity，见本节末尾的 Mac 文档。

### Bootstrap 密钥

在部署系统配置（`nixos-rebuild switch`）前，目标系统必须有：

```
/etc/ssh/ssh_host_ed25519_key
```

NixOS 层直接使用它解密 secrets：

```nix
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
```

系统激活时会从这把 host key 派生 Home Manager 使用的 age identity：

```
/home/tohno/.config/sops/age/keys.txt
```

Home Manager 只读取这个派生文件：

```nix
sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
```

### 首次安装（Live ISO）

首次安装时目标系统尚未建立，密钥需要放到 `/mnt` 下：

```
# 假设你把密钥存在 U 盘，挂载在 /run/media/usb
mkdir -p /mnt/etc/ssh
cp /run/media/usb/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key
chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
```

然后正常执行 `nixos-install`，sops-nix 就能在构建阶段解密 secrets。

> 如果你没有 U 盘，也可以用 `scp` 从另一台机器拉取，或者挂载一个已有的加密分区。关键是在 `nixos-install` 之前，`/mnt/etc/ssh/ssh_host_ed25519_key` 必须存在。

### 后续部署（已安装 NixOS）

1. 确认 `/etc/ssh/ssh_host_ed25519_key` 存在
2. `sudo nixos-rebuild switch --flake .#<host>` — 使用 `/etc/ssh/ssh_host_ed25519_key` 解密系统级 secrets
3. `home-manager switch --flake .#<user@host>` — 使用系统激活时派生的 `~/.config/sops/age/keys.txt` 解密用户级 secrets

> 注意：`user/modules/activation.nix` 会在 home-manager 激活时清理 `~/.ssh` 下残留的 Nix store 符号链接，确保 SSH 权限检查不会因错误的文件类型而拒绝密钥。

macOS 使用独立的 age identity，已加入现有密文的授权列表，不依赖 NixOS SSH host key bootstrap。Mac sing-box 在 launchd 启动时通过 SOPS 解密所需节点；操作和测试见 [Mac sing-box](tools/sing-box/mac.md)，密钥准备流程见 [Mac age 密钥准备](tools/sing-box/mac-age.md)。
