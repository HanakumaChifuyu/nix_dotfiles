# NixOS Dotfiles

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

### 后续部署（已安装系统）

1. 确认 `/etc/ssh/ssh_host_ed25519_key` 存在
2. `sudo nixos-rebuild switch` — 使用 `/etc/ssh/ssh_host_ed25519_key` 解密系统级 secrets
3. `home-manager switch` — 使用系统激活时派生的 `~/.config/sops/age/keys.txt` 解密用户级 secrets

> 注意：`user/modules/activation.nix` 会在 home-manager 激活时清理 `~/.ssh` 下残留的 Nix store 符号链接，确保 SSH 权限检查不会因错误的文件类型而拒绝密钥。
