{
  description = "skyepkgs - Personal Nix package repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      lib = import ./lib { inherit (nixpkgs) lib; };
      overlay = import ./overlay.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, config, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
          allPkgs = import ./pkgs { inherit pkgs lib; };
          availablePkgs = lib.filterAttrs (_: p: lib.meta.availableOn pkgs.stdenv.hostPlatform p) (
            removeAttrs allPkgs [ "vimPlugins" ]
          );
        in
        {
          packages = availablePkgs;

          legacyPackages.vimPlugins = allPkgs.vimPlugins;

          checks = availablePkgs;

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.statix.enable = true;
          };

          devShells.default = pkgs.mkShell {
            name = "skyepkgs";
            buildInputs = with pkgs; [
              nix-update
              nixd
              nixfmt
              just
            ];
          };
        };

      flake = {
        inherit lib;

        overlays.default = overlay;

        homeManagerModules = {
          opencode-monitor = import ./modules/home-manager/opencode-monitor.nix;
          iterm2-shell-integration = import ./modules/home-manager/iterm2-shell-integration.nix;
          default = import ./modules/home-manager/default.nix;
        };

        templates.ruby = {
          path = ./templates/ruby;
          description = "A Ruby project using ruby-nix and bundix";
        };
        templates.trivial = {
          path = ./templates/trivial;
          description = "A basic flake template for devshells.";
        };
      };
    };
}
