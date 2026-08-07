{
  description = "Minimal NixOS configurations for VPS hosts";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      mkVps = hostModule: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/base.nix
          ./modules/ssh.nix
          ./modules/services.nix
          hostModule
        ];
      };
    in
    {
      # A terminal-only QEMU VM for safely testing the shared VPS modules.
      nixosConfigurations.vps_test = mkVps ./hosts/test-vm;
    };
}
