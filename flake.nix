{
  description = "skyepkgs - Personal Nix package repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      lib = import ./lib { inherit (nixpkgs) lib; };
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = import ./pkgs { inherit pkgs lib; };

        checks = self.packages.${system};

        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      lib = lib;
      overlays.default = overlay;
    };
}
