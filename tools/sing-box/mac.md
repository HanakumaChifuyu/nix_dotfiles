# Mac sing-box 配置与测试

首次安装与系统、用户配置的激活顺序见 [MacBook 部署手册](../../hosts/macbook/README.md)，
密钥生成与授权见 [age 密钥准备](mac-age.md)。

Mac 使用与 Linux 相同的 DNS、分流和固定版本规则集，仍提供 `127.0.0.1:7890`。
Fish 的全局代理变量保持原样。平台入口是 `hosts/macbook/sing-box.nix`，
共享策略在 `modules/sing-box-settings.nix`，Linux 入口仍是 `modules/sing-box.nix`。

Mac 通过 root launchd daemon 运行原生 sing-box 1.13.13，自动分配 `utun` 接口。
不使用 Linux 的 `auto_redirect`/`strict_route`，普通出口自动绑定当前默认网卡。
LAN/Tailscale 使用独立的本地出口及路由排除，避免被强制绑定到物理网卡。
当前 Mac 没有运行 Tailscale，其共存行为需要安装后再实际验证。

## 启用前检查

在仓库根目录进入 Bash，构建独立管理命令，不会启用任何系统服务：

```bash
bash
singbox_mac_package=$(nix build --no-link --print-out-paths .#darwinConfigurations.macbook.config.system.build.singBoxMac)
"$singbox_mac_package/bin/sing-box-mac" check
"$singbox_mac_package/bin/sing-box-mac" proxy-test
```

`check` 使用 Mac age identity 解密大阪节点，生成临时配置并执行 `sing-box check`。
`proxy-test` 只启动独立的 `127.0.0.1:19890` 代理，验证 Hysteria2 和清华镜像直连，
退出后停止测试进程并清理临时配置。它不会改动系统 DNS、TUN 或代理环境变量。
如 19890 被占用，可用 `--port 19891 proxy-test`。

## 临时测试系统 TUN

先关闭 FlClash 的 TUN/系统代理并退出 FlClash，再在上述 Bash 终端执行：

```bash
sudo "$singbox_mac_package/bin/sing-box-mac" run
```

保持此终端运行，在另一个终端测试：

```bash
dig @223.5.5.5 example.org A +short
dig @1.1.1.1 example.org A +short
dig +tcp @223.5.5.5 example.org A +short
dig @172.19.0.2 example.org A +short
dig example.org A +short
dig @223.5.5.5 mirrors.tuna.tsinghua.edu.cn A +short
curl --proxy '' --noproxy '*' --fail --max-time 30 https://www.gstatic.com/generate_204
curl --proxy http://127.0.0.1:7890 --noproxy '' --head --fail --max-time 30 https://mirrors.tuna.tsinghua.edu.cn/
```

前五个 DNS 查询应返回 `198.18.0.0/15` 内的 FakeIP，镜像域名应返回实际地址。
`route -n get 172.19.0.2` 的接口应为 sing-box 的 `utun`，不能是物理网卡。
第一个 curl 显式绕过代理环境变量，检验 TUN；正常应成功退出且没有正文。
第二个 curl 验证原有 7890 入口。再检查日常网页、Steam 和局域网设备。

测试结束在服务终端按 Ctrl-C，程序会恢复先前的 DNS 并停止 TUN。
只有临时测试正常后，再启用开机服务。

若提示 7890 被占用，用 `sudo lsof -nP -iTCP:7890 -sTCP:LISTEN` 查看实际监听者。
FlClash 的内核以 root 运行，普通 `lsof` 可能看不到；关闭窗口也不代表内核退出。
先在 FlClash 中停止连接并彻底退出，再启动 sing-box。
端口预检允许已关闭连接的 TIME_WAIT 状态，仍会拒绝真正存在的监听者。

## 启用 launchd 服务

首次从前台测试切换时，保持前台实例运行，在另一个终端应用 Mac 系统配置：

```bash
sudo darwin-rebuild switch --flake .#macbook
```

应用成功后，在原前台实例的终端按 Ctrl-C。等待约 15 秒后，launchd 会接管：

```bash
sudo launchctl print system/org.nixos.sing-box
sudo tail -n 80 /var/log/sing-box.log
```

交接期间新实例可能提示 `already running`；这是互斥锁在保护现有网络配置。
旧实例退出后，launchd 会自动重试，无需再次手动运行 `sing-box-mac run`。
后续开机由 launchd 自动启动。若启动时暂时无法读取 age 私钥或网络尚未就绪，
失败后每隔至少 15 秒重试。

服务以 root 身份运行；运行时配置和 DNS 恢复记录位于 `/var/lib/sing-box`，
目录权限 `700`，配置权限 `600`。日志位于 `/var/log/sing-box.log`。
程序从 `~tohno/.config/sops/age/keys.txt` 读取私钥，在运行时只解密所需节点。
私钥和明文凭据不会进入 Nix store；存入 store 的只是加密文件和无密钥模板。
密文更新后需重新构建系统，使服务引用新的加密文件。

## 停止与恢复

```bash
sudo launchctl bootout system/org.nixos.sing-box
```

正常停止会自动恢复 DNS。若被强制杀死、或上次恢复失败，先确保服务已停止，再执行：

```bash
sudo sing-box-mac restore-dns
```

程序会把手动 DNS 恢复为原地址列表，把原先自动获取 DNS 的服务恢复为 `Empty`。
运行期间用户自行修改过的 DNS 会保留，恢复失败时会保留记录供重试。
异常退出后 launchd 重启程序时，也会先尝试恢复旧记录再重新启动。
停止后如需继续使用 FlClash，可重新打开其 TUN。

`bootout` 只停止本次运行；恢复启动可执行：

```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.sing-box.plist
```

要长期停用，从 `hosts/macbook/configuration.nix` 移除 `./sing-box.nix` 导入并重新
`darwin-rebuild switch`。停用期间保留管理命令的构建路径，可用于手动恢复 DNS。

## 回归测试

```bash
PYTHONDONTWRITEBYTECODE=1 python3 tools/sing-box/test_mac_service.py
nix build --no-link .#darwinConfigurations.macbook.system
```

无网络测试覆盖 DHCP/手动 DNS 恢复、异常重启、用户修改 DNS、新网络服务、部分失败、
并发启动保护、运行时密钥注入、端口重用和 TUN 子网排除。
本机已验证系统 DNS、UDP/TCP DNS 劫持、TUN HTTPS、7890 代理和镜像直连。
开机启动及 Wi-Fi/网线切换仍需在应用系统配置后进一步验证。
