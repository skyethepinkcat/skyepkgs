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
let
  overlay-pkgs = import ./pkgs {
    pkgs = final;
    lib = import ./lib { inherit (prev) lib; };
  };
in
overlay-pkgs
// {
  vimPlugins = prev.vimPlugins // overlay-pkgs.vimPlugins;
}
