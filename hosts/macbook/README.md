# MacBook / nix-darwin 部署手册

本文对应本仓库当前的 Mac 配置。除特别说明外，命令都在仓库根目录执行。
带有变量赋值的代码块使用 Bash；如果当前是 Fish，先执行 `bash`。

## 配置入口

| 项目 | 当前配置 |
| --- | --- |
| 平台 | Apple Silicon，`aarch64-darwin` |
| 系统 flake 入口 | `darwinConfigurations.macbook` |
| Home Manager 入口 | `homeConfigurations."tohno@macbook"` |
| 已有 macOS 用户 / 家目录 | `tohno` / `/Users/tohno` |
| 系统配置 | [configuration.nix](configuration.nix) |
| 用户配置 | [home.nix](../../user/hosts/macbook/home.nix) |
| sing-box 服务 | `org.nixos.sing-box`，本地端口 `7890` |

系统配置与 Home Manager 独立激活。改系统服务、字体、Homebrew 或 macOS defaults，
执行 `darwin-rebuild switch`；改用户 dotfiles、用户软件包、键盘规则或输入法配置，
执行 `home-manager switch`。同时修改两层时，先系统层，再用户层。

不要使用旧文档中的 `mac@macbook`，本仓库没有这个 Home Manager 入口。
另一位用户使用此仓库时，需要同时调整 flake 的 Home Manager 名称、系统用户、
`system.primaryUser`、Homebrew 用户、Home Manager 用户和家目录，以及 sing-box 的 identity 路径。
Intel Mac 还需要调整系统与 Home Manager 的平台；当前配置只在 Apple Silicon 上验证。

## 首次部署

### 1. 准备 Nix 和仓库

先安装支持 macOS 的 Nix 实现，再使用本仓库。nix-darwin 本身通过系统配置激活完成安装；
安装器选择和前置条件以 [nix-darwin 官方说明](https://github.com/nix-darwin/nix-darwin#prerequisites)
和 [Nix 下载页](https://nixos.org/download/)为准。已有可用 Nix 时无需重复安装。

```bash
nix --version
uname -m
whoami
```

本机预期为 `arm64`、`tohno`。通过 Git 取得此仓库，进入仓库根目录，并保留 `flake.lock`。
首次尚未开启 flakes 时，临时在当前 Bash 中启用：

```bash
export NIX_CONFIG='experimental-features = nix-command flakes'
```

系统激活后，[nix-settings.nix](../../modules/nix-settings.nix) 会持久开启这些特性。
初次下载仍需一个可用的网络出口，可以继续使用已有代理。Fish 配置固定使用
`127.0.0.1:7890`；sing-box 尚未接管时，应确保已有代理可提供该入口。

### 2. 准备 age identity 和节点授权

新 Mac 不会因拉取仓库而获得私钥。先按 [age 密钥准备](../../tools/sing-box/mac-age.md)
恢复已有 identity 或生成新 identity，并在已授权机器上更新密文 recipients。
本机现有 identity 已授权，不必重新生成。

```bash
nix shell --inputs-from . nixpkgs#age nixpkgs#sops -c bash tools/sing-box/check-mac-age.sh --require-secrets
```

严格检查必须成功后再启用 sing-box。私钥位于 `~/.config/sops/age/keys.txt`，权限 `600`，
目录权限 `700`。私钥不进入 Git，节点明文也不进入 Nix store。

如果这台 Mac 暂时不需要代理，可先从 [configuration.nix](configuration.nix) 的 imports
移除 `./sing-box.nix`；准备好 identity 后再加回来。默认配置会启用该服务。

### 3. 构建与代理预检

```bash
nix build --no-link .#darwinConfigurations.macbook.system
nix build --no-link '.#homeConfigurations."tohno@macbook".activationPackage'
```

这两条只构建，不修改系统或用户配置。新增 Nix 模块必须先 `git add`，才能被 Git flake 收入构建。
sing-box 的独立端口预检、临时 TUN 测试见 [Mac sing-box 测试](../../tools/sing-box/mac.md)。
不要同时运行两个代理的 TUN；关闭 FlClash 窗口不等于停止它的 root 内核。

### 4. 首次激活系统层

还没有 `darwin-rebuild` 命令时，使用仓库锁定的 nix-darwin 输入：

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run --inputs-from . nix-darwin#darwin-rebuild -- switch --flake .#macbook
```

若已安装，则直接执行：

```bash
sudo darwin-rebuild switch --flake .#macbook
```

首次从前台 sing-box 测试实例交接时，保持该实例运行，在另一个终端执行系统激活。
激活完成后对前台实例按 Ctrl-C，等待约 15 秒，launchd 会自动接管。
互斥锁会阻止新旧实例同时修改网络，期间短暂出现 `already running` 是预期行为。
如果没有前台实例，应用配置会直接启动开机服务。

### 5. 首次激活用户层

不需要先全局安装 Home Manager，可直接构建并运行本仓库用户配置的激活脚本：

```bash
mac_home_package=$(nix build --no-link --print-out-paths '.#homeConfigurations."tohno@macbook".activationPackage')
"$mac_home_package/activate"
```

此步骤以 `tohno` 运行，不加 sudo。成功后重新打开终端，后续使用：

```bash
home-manager switch --flake '.#tohno@macbook'
```

用户包列表已经包含 `home-manager`、`age` 和 `sops`，无需另外安装。
若已有 dotfiles 发生冲突，按错误信息逐个备份冲突文件，再重试激活。

## 软件和桌面配置

| 配置 | 来源与行为 |
| --- | --- |
| Homebrew | [homebrew.nix](homebrew.nix)：迁移已有安装，启用 Rosetta Homebrew 支持 |
| GUI 软件 | Homebrew casks 安装 Karabiner-Elements 和 Squirrel |
| Homebrew 更新 | 系统激活时 `autoUpdate = true`，`upgrade = false`，`cleanup = "none"` |
| 字体 | [fonts.nix](fonts.nix)：Nerd Fonts、中日韩字体及仓库内字体 |
| 键盘重复 | 系统层设置 `KeyRepeat = 1`、`InitialKeyRepeat = 27`，关闭长按选字菜单 |
| 鼠标速度 | 系统层将鼠标跟踪速度设为 `1.5`（默认值 `1.0` 的 150%），不修改触控板速度 |
| 键盘映射 | [karabiner.nix](../../user/hosts/macbook/karabiner.nix)：交换 Command/Option、Alt+1–9/0 切换桌面、Alt+Q 关闭窗口、Alt+Shift+Q 退出应用、Alt+A 切换窗口填充、Caps 短按 Escape / 长按 Control 等 |
| 鼠须管 | [rime.nix](../../user/hosts/macbook/rime.nix)：初始化雾凇拼音，部署仓库内 Rime 配置 |
| 动态配色 | [matugen.nix](../../user/modules/matugen.nix)：生成 Kitty、Neovim、Yazi、btop 和鼠须管颜色 |

Homebrew 的 `autoUpdate` 更新 Homebrew 元数据，并不等同于执行所有已安装软件的升级。
应用系统配置可能访问 Homebrew 网络源，因此“系统构建完成”不等同于“激活完全离线”。

首次打开 Karabiner-Elements 时，按应用提示完成 macOS 权限与驱动授权。
Nix 管理的键盘配置位于 `~/.config/karabiner/karabiner.json`，应修改仓库源文件，
不要只在生成的配置文件中修改。首次安装鼠须管后，在系统输入法设置中添加它，必要时重新登录。

Karabiner 会交换左右 Command 和 Option：物理 Option 键执行 macOS Command 快捷键，
物理 Command 键作为 Alt 使用。按物理 Command+1–9/0 可切换主显示器的桌面 1–10；
目标桌面尚未创建时会显示通知。Mission Control 的 Control+数字快捷键由 Home Manager
激活脚本启用；首次应用后如果桌面切换尚未生效，请注销并重新登录一次。
物理 Command+Q 关闭当前窗口，物理 Command+Shift+Q 正常退出当前应用；物理
Command+A 在填充当前窗口和恢复平铺前尺寸之间切换。

Rime 用户数据位于 `~/Library/Rime`。若缺少 `rime_ice.schema.yaml`，当前激活脚本会
初始化该目录，并清理除 `rime_ice.userdb` 之外的已有内容；已有自定义输入方案时先备份该目录。
`default.yaml`、`squirrel.custom.yaml` 每次用户激活都会从仓库复制。

切换壁纸和生成主题可使用：

```bash
matugen-wallpaper /absolute/path/to/wallpaper.jpg
```

脚本也接受相对路径，例如 `matugen-wallpaper ./wallpaper.jpg`。

生成结果位于 `~/.cache/matugen`，鼠须管配色写入 `~/Library/Rime/matugen.yaml`。
这些是生成文件，持久修改应写入仓库中的 Matugen 模板。壁纸控制首次执行时可能需要系统授权。

## 日常更新

拉取配置后按需要激活两层，不必每次更新依赖：

```bash
git pull --ff-only
sudo darwin-rebuild switch --flake .#macbook
home-manager switch --flake '.#tohno@macbook'
```

单独更新某个 flake 输入会修改 `flake.lock`，例如：

```bash
nix flake update nixpkgs-unstable
git diff -- flake.lock
```

此命令只更新依赖锁定状态，不激活配置。检查差异并重新构建后，再应用对应层。
跨版本升级时检查 NixOS、nix-darwin、Home Manager 的输入分支兼容性；不要把
`system.stateVersion` 或 `home.stateVersion` 当作软件版本号随手提升。

更新 sing-box 节点密文后需要重新应用系统层；更新固定规则集时，应同时更新
[sing-box-rules.nix](../../modules/sing-box-rules.nix) 的 revision 与 hashes。
当前规则集不会在运行时自动跟随上游 `main`。

## 服务管理和恢复

```bash
sudo launchctl print system/org.nixos.sing-box
sudo tail -n 80 /var/log/sing-box.log
sing-box-mac check
```

`launchctl print` 中应能看到服务处于运行状态；7890 由 sing-box 监听，系统 DNS 应为 `172.19.0.2`。
只有查看配置通过不足以证明网络可用，完整网络验收命令见 [代理测试文档](../../tools/sing-box/mac.md)。

临时停止：

```bash
sudo launchctl bootout system/org.nixos.sing-box
```

正常退出会恢复 DNS。如果上次被强制终止，停止服务后运行 `sudo sing-box-mac restore-dns`。
恢复开机服务的本次运行：

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.sing-box.plist
```

`bootout` 不会从 Nix 配置中移除服务。长期停用需移除对应 import，再激活系统配置。
不要删除 `/var/lib/sing-box/dns-state.json` 来修复 DNS；这是恢复原 DNS 的记录。

## 回滚

系统层可以查看并退回上一代：

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild --rollback
```

Home Manager 独立保存用户配置代：

```bash
home-manager generations
```

从输出中选择需要恢复的 `/nix/store/...-home-manager-generation` 路径，运行该目录中的
`activate`，不加 sudo。系统回滚不会同时回滚用户配置；Homebrew 软件、Rime 用户数据等
激活脚本产生的外部改动，也不保证随 Nix generation 自动还原。

## 常见问题

| 现象 | 检查和处理 |
| --- | --- |
| 找不到 `tohno@macbook` | 确认在仓库根目录，使用 `--flake '.#tohno@macbook'`，不要使用旧名称 `mac@macbook` |
| 命令未找到 | 首次使用上述 bootstrap 命令；已激活则重新打开终端，检查 `/run/current-system/sw/bin` 是否在 PATH |
| 7890 被占用 | `sudo lsof -nP -iTCP:7890 -sTCP:LISTEN`；检查 FlClashCore 或另一个前台 sing-box |
| launchd 报 `already running` | 前台实例还持有锁；停止它并等待 launchd 接管，不要反复启动新实例 |
| `SOPS could not decrypt` | 执行严格 age 检查，确认本机 identity 已加入密文授权列表及文件权限正确 |
| 代理端口能用，普通应用解析超时 | 检查 `dig example.org A +short` 和 `route -n get 172.19.0.2`；DNS 的路由接口应是 `utun` |
| Nix 下载时 DNS 超时 | 先修复运行中的 DNS/代理；依赖已缓存时可用 `nix build --offline --no-link .#darwinConfigurations.macbook.system` 构建，缺失依赖时仍需联网 |
| Home Manager 没应用 sing-box 改动 | sing-box 是系统服务，需 `sudo darwin-rebuild switch --flake .#macbook` |
| 输入法或配色改完没变化 | 应用 Home Manager 配置，再检查 Rime 生成文件、鼠须管部署/重载及 Matugen 输出 |

本仓库当前已通过 Mac 系统构建、14 项服务回归测试和 9 项本机网络检查。
重启后启动、睡眠唤醒、网卡切换以及 Tailscale 共存，仍需按实际使用情况继续验收。
