{
  description = "A very basic dev flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            name = "my-project-shell";
            packages = with pkgs; [
            ];
            shellHook = ''
              exec fish
            '';

          };

          # Chose different function for your languages
          # pkgs.stdenv.mkDerivation
          # pkgs.rustPlatform.buildRustPackage
          # pkgs.buildGoModule
          # pkgs.python3.pkgs.buildPythonApplication
          packages.default = pkgs.stdenv.mkDerivation {

            nativeBuildInputs = [
              pkgs.git
            ];

            buildInputs = [
              pkgs.glib
            ];

            meta = {
              description = "A sample nix package";
              homepage = "https://github.com/your/repo";
              license = pkgs.lib.licenses.mit;
              maintainers = [ ];
              platforms = pkgs.lib.platforms.linux;
            };

          };
        };
    };
}
