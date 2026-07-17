{
  description = "NixOS system configuration with advanced flake-parts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      nixpkgs-unstable,
      nix-darwin,
      nix-homebrew,
      home-manager,
      sops-nix,
      disko,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      debug = true;

      flake = {
        darwinConfigurations = {
          macbook = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              nix-homebrew.darwinModules.nix-homebrew
              ./hosts/macbook/configuration.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };

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

          nas = nixpkgs.lib.nixosSystem {
            system = builtins.head (inputs.self.systems or [ "x86_64-linux" ]);
            modules = [
              ./hosts/nas/configuration.nix
              inputs.sops-nix.nixosModules.sops
              disko.nixosModules.disko
            ];
          };

        };

        homeConfigurations =
          let
            mkHome =
              system: modules:
              home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.${system};
                inherit modules;
                extraSpecialArgs = {
                  inherit inputs;
                  unstable = nixpkgs-unstable.legacyPackages.${system};
                };
              };
          in
          {
            "tohno@desktop" = mkHome "x86_64-linux" [
              ./user/hosts/desktop/home.nix
              sops-nix.homeManagerModules.sops
            ];

            "tohno@gpu" = mkHome "x86_64-linux" [
              ./user/hosts/gpu/home.nix
              sops-nix.homeManagerModules.sops
            ];

            "mac@macbook" = mkHome "aarch64-darwin" [
              ./user/hosts/macbook/home.nix
            ];
          };
      };

    };
}
