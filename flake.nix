{
  description = "NixOS system configuration with advanced flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      home-manager,
      sops-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      debug = true;

      flake = {
        nixosConfigurations = {

          desktop_nixos = nixpkgs.lib.nixosSystem {
            system = builtins.head (inputs.self.systems or [ "x86_64-linux" ]);
            modules = [
              ./hosts/desktop-nixos/configuration.nix
              inputs.sops-nix.nixosModules.sops
            ];
          };

          gpu_nixos = nixpkgs.lib.nixosSystem {
            system = builtins.head (inputs.self.systems or [ "x86_64-linux" ]);
            modules = [
              ./hosts/gpu-nixos/configuration.nix
              inputs.sops-nix.nixosModules.sops
            ];
          };

        };

        homeConfigurations =
          let
            system = builtins.head (inputs.self.systems or [ "x86_64-linux" ]);
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            "tohno@desktop" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./user/hosts/desktop/home.nix
                sops-nix.homeManagerModules.sops
              ];
              extraSpecialArgs = { inherit inputs; };
            };

            "tohno@gpu" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./user/hosts/gpu/home.nix
                sops-nix.homeManagerModules.sops
              ];
              extraSpecialArgs = { inherit inputs; };
            };
          };
      };

    };
}
