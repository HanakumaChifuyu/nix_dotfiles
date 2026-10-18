# 按需启动的远程图形会话

labwc 提供浮动窗口 Wayland 会话，Sunshine 通过局域网向 Mac 的 Moonlight
串流。没有开机自启、显示管理器或 VNC。当前针对 NVIDIA 主机验证，尚未完成
真实硬件上的画面、输入和 Vulkan 验证。

## 启用与部署

在主机模块中导入并启用（nas-5060ti-16G 已配置）：

```nix
imports = [ ../../modules/remote-desktop ];
services.remoteDesktop = {
  enable = true;
  user = "tohno";
};
```

在 NAS 的仓库根目录执行；如果使用 Git flake，先让新增文件进入 Git 索引：

```sh
git add modules/remote-desktop hosts/nas-5060ti-16G/configuration.nix
sudo nixos-rebuild switch --flake .#nas_gpu
```

Sunshine 显式启用了 CUDA 构建以支持 NVENC；缓存未命中时可能需要较长时间构建。
NVIDIA 驱动、hardware.graphics 和 allowUnfree 仍由主机负责。
切换系统后重新登录（重新建立 SSH 连接），让 seat/video/render 用户组生效。

## 启动、连接与停止

以 tohno 普通用户运行，不要使用 sudo：

```sh
systemctl --user start labwc-remote
systemctl --user status labwc-remote
journalctl --user -u labwc-remote -f
```

Mac 浏览器打开 `https://<NAS局域网IP>:47990`，设置 Sunshine 账号密码。
首次访问为自签名证书。Moonlight 手动添加 NAS 局域网 IP，在 Sunshine 的 PIN
页面输入 Moonlight 显示的配对码，然后选择 Desktop。

默认虚拟输出 HEADLESS-1 为 1920×1080、60 Hz。连接后会有终端窗口，
空白处右键菜单可以启动终端、Vulkan 演示和切换窗口。

```sh
systemctl --user stop labwc-remote
```

停止会终止这个服务内的应用。无需 `enable`；不配置 linger，最后一个登录会话
退出后，用户服务能否继续保留由系统用户会话策略决定。首次测试请保留 SSH 连接。
不要另行启动 `sunshine.service`：它会与会话内的 Sunshine 争用端口。

## 验证与排错

在远程画面中的终端执行：

```sh
wlr-randr
vulkaninfo --summary
vkcube-wayland
```

检查 Vulkan 选中的设备确实为 RTX 5060 Ti，而不是软件设备。
检查 Sunshine 日志是否成功使用 wlr 捕获和 NVENC；Vulkan 渲染与视频编码需分别验证。
这里强制 GLES2 compositor 渲染器，但这本身不是 NVIDIA Vulkan 正常工作的证据。

无头后端、NVIDIA 驱动和 Sunshine 的兼容性需要实机验证。如果出现缺少 Wayland
捕获协议、黑屏或 EGL 初始化失败，保留完整服务日志；不应改用 KMS 去捕获一个
不存在的物理显示输出。可能需要调整 Sunshine 捕获方式（例如 portal），并补齐
对应会话集成。

会话使用 headless + libinput，通过 seatd 接收 Sunshine 的 uinput 键鼠。
如有画面但无法操作，检查 seatd、用户组和设备权限。这种配置不提供多会话输入隔离，
也可能接入本机物理输入，当前仅用于单个远程会话。没有配置音频服务；音频需另行验证。

配置文件由 Nix 管理；菜单在 config/ 中，分辨率和 Sunshine 参数在 labwc.nix 中。
Sunshine 账号、证书和配对状态保存在用户的默认 Sunshine 配置目录，不放进 Nix store。
模块通过 Sunshine 的 openFirewall 开放串流及管理端口，范围受主机网络可达性影响，
不会自动限制到某个 LAN 接口；不应在路由器上转发这些端口。

## 文件分工

- default.nix：模块选项、用户组和 seatd。
- labwc.nix：隔离的运行时目录、会话脚本、手动启动的用户服务。
- sunshine.nix：CUDA/NVENC 构建、uinput、发现和防火墙配置。
- config/：鼠标操作和右键菜单。

参考：[labwc](https://labwc.github.io/labwc.1.html)、
[Sunshine](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html)。
