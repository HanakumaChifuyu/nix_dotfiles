# VPS NixOS configurations

This is an intentionally independent, minimal flake. It does not import the
repository root `configuration.nix`, desktop modules, Home Manager profiles, or
NAS configuration.

## Test locally

The test VM is terminal-only and uses the temporary credentials `vps` / `vps`.

```sh
cd vps
nix build .#nixosConfigurations.vps_test.config.system.build.vm
./result/bin/run-vps-test-vm
```

The generated `vps-test.qcow2` is persistent. Delete it before rerunning when
you need a fresh VM disk.

## Add a real VPS

1. Copy `hosts/example` to `hosts/<provider>-<region>`.
2. On the target NixOS host, generate its hardware module:

   ```sh
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. Set the hostname and replace the example SSH public key.
4. Add the host to `nixosConfigurations` in `flake.nix`, for example:

   ```nix
   nixosConfigurations.vps_hk = mkVps ./hosts/vps-hk;
   ```

5. On that VPS, activate it with:

   ```sh
   sudo nixos-rebuild switch --flake .#vps_hk
   ```

The `hardware-configuration.nix` file is per-machine; shared services belong
in `modules/`.
