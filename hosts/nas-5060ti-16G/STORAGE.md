# 将 tohno 的 home 放到 XFS 数据盘

布局：`LABEL=nas-data` → `/data`，`/data/home/tohno` → bind mount 到
`/home/tohno`。`/nix` 和其他用户的 home 保持原位。

仅声明挂载，不会格式化、复制文件或删除旧 home。
由于 sops 的 age 密钥位于 home，两个挂载均在早期启动完成。
数据盘和 home 因而是必需的启动依赖；缺盘或挂载失败可能进入恢复模式。

## 首次迁移（NAS 上执行）

不要直接 `nixos-rebuild switch` 覆盖正在使用的 home。
先保留当前可启动的系统 generation 和原 home，准备好本地维护控制台。

1. 确认文件系统已经是 XFS、标签是 nas-data，且没有其他设备使用相同标签：

   ```sh
   lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS
   sudo blkid /dev/disk/by-label/nas-data
   ```

   若尚未设置标签，先确认实际分区，并在卸载状态下使用
   `xfs_admin -L nas-data /dev/实际分区`。不要为修改标签而重新格式化。

2. 挂载数据盘。若已经挂载到其他位置，先检查并使用一致的挂载位置：

   ```sh
   sudo mkdir -p /data
   sudo mount /dev/disk/by-label/nas-data /data
   findmnt /data
   ```

   确认 `/data` 确实是目标 XFS 数据盘之后，再创建目录和复制。
   没有 rsync 时可先运行 `nix shell nixpkgs#rsync`。

   ```sh
   sudo mkdir -p /data/home/tohno
   sudo rsync -aHAXS --numeric-ids /home/tohno/ /data/home/tohno/
   ```

   末尾斜杠不能省略；复制包含隐藏文件、SSH 密钥、sops 密钥及 Home Manager 配置，
   并保留 UID/GID、权限和扩展属性。若 home 内有额外挂载，先单独检查复制范围。

3. 在 NAS 的仓库根目录构建下次启动配置（Git flake 需先跟踪新增文件）：

   ```sh
   git add hosts/nas-5060ti-16G/storage.nix hosts/nas-5060ti-16G/STORAGE.md hosts/nas-5060ti-16G/configuration.nix
   sudo nixos-rebuild boot --flake .#nas_gpu
   ```

   `boot` 不会立刻切换正在使用的 home。

4. 在独立的 root 维护控制台中，退出 tohno 的所有会话并停止其后台程序和用户服务。
   不要从即将终止的 tohno SSH 会话执行用户终止操作。确保没有进程继续写入旧 home，
   然后做最后一次同步：

   ```sh
   rsync -aHAXS --numeric-ids /home/tohno/ /data/home/tohno/
   rsync -aHAXSn --numeric-ids --itemize-changes /home/tohno/ /data/home/tohno/
   sync
   ```

   检查试运行无意外差异，尤其确认 `.ssh`、`.config/sops/age/keys.txt` 的内容和权限。
   同步没有使用 `--delete`，不会自动清理目标盘上的多余文件。
   重启进入新 generation。

5. 重启后验证：

   ```sh
   findmnt -T /home/tohno
   findmnt /data
   df -h / /home/tohno /nix
   ```

   确认登录、SSH、sops 和 Home Manager 正常后，再考虑清理 SSD 上的旧 home。
   bind mount 会遮住原目录，因此迁移完成前后都不要直接对 `/home/tohno` 执行删除。
   保留旧目录期间 SSD 空间不会立即释放。

如启动失败，在启动菜单选择旧 generation；旧 home 没有被移动或删除。
