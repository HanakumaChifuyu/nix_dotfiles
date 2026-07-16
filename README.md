# NixOS Dotfiles

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

MacBook 首次部署时，系统里还没有 `darwin-rebuild` 和 `home-manager` 命令，需要都通过 `nix run` 临时调用。

阶段 1：首次激活 nix-darwin 系统层：

```sh
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#macbook
```

阶段 2：首次激活 Home Manager 用户层：

```sh
nix --extra-experimental-features "nix-command flakes" run github:nix-community/home-manager/release-26.05 -- switch --flake .#mac@macbook
```

`nix run` 只是在首次部署时临时调用 Home Manager，本身不会把 `home-manager` 命令安装到用户环境里。本仓库的 Mac Home Manager profile 会通过 `home.packages` 持久安装 `home-manager`，所以上面这次激活成功后，后续就可以直接使用 `home-manager switch`。

后续部署：

```sh
sudo darwin-rebuild switch --flake .#macbook
home-manager switch --flake .#mac@macbook
```

`macbook` 当前按 Apple Silicon 配置为 `aarch64-darwin`。如果目标机器是 Intel Mac，需要把 flake 里的 system 改为 `x86_64-darwin`，并相应调整 `homeConfigurations."mac@macbook"` 使用的 system。

## 密钥管理

本项目使用 [sops-nix](https://github.com/Mic92/sops-nix) 管理 secrets，系统和 Home Manager 都以 SSH host key 作为 bootstrap 密钥：

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

macOS 的 Home Manager profile 当前没有启用 `sops-nix`，因此不依赖上面的 NixOS SSH host key bootstrap 流程。后续如果要在 macOS 上解密 secrets，需要先给 Mac 生成 age identity，把 public key 加进 `.sops.yaml`，再在 Mac 的 Home Manager profile 中启用对应的 sops module。
