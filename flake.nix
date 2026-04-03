{
  description = "skyepkgs - Personal Nix package repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    let
      lib = import ./lib { inherit (nixpkgs) lib; };
      overlay = import ./overlay.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { system, config, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        {
          packages = import ./pkgs { inherit pkgs lib; };

          checks = config.packages;

          formatter = pkgs.nixfmt;

          devShells.default = pkgs.mkShell {
            name = "skyepkgs-dev-shell";
            buildInputs = with pkgs; [
              nixfmt
              nil
            ];
          };
        };

      flake = {
        inherit lib;

        overlays.default = overlay;

        templates.ruby = {
          path = ./templates/ruby;
          description = "A Ruby project using ruby-nix and bundix";
        };
      };
    };
}
