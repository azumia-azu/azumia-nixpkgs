{
  description = "AzumiA personal nixpkgs-like package source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem =
        { system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          packages = {
            default = pkgs.ghosttyfetch;

            inherit (pkgs)
              ghosttyfetch
              pdmaas
              toofan
              ;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              git
              nil
              nixfmt
              nix-output-monitor
              zig_0_15
            ];
          };
        };

      flake = {
        lib = import ./lib { inherit (nixpkgs) lib; };

        overlays = import ./overlays {
          inherit (nixpkgs) lib;
          myLib = self.lib;
        };

        nixosModules = import ./modules/nixos { myLib = self.lib; };

        homeManagerModules = import ./modules/home-manager { myLib = self.lib; };
      };
    };
}
