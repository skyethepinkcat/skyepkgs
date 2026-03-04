# skyepkgs overlay
#
# Adds all skyepkgs packages on top of nixpkgs so that they are available
# directly via `pkgs.<name>`.
#
# Usage (non-flake):
#   pkgs = import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; };
#
# Usage (flake, already wired up in flake.nix):
#   nixpkgs.overlays = [ skyepkgs.overlays.default ];
final: prev:
import ./pkgs {
  pkgs = final;
  lib = import ./lib { inherit (prev) lib; };
}
