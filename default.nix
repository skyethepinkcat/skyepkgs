# skyepkgs - legacy (non-flake) entry point
#
# Usage:
#   pkgs = import <nixpkgs> {};
#   skyepkgs = import /path/to/skyepkgs { inherit pkgs; };
#   # then use skyepkgs.hello-skyepkgs, etc.
{ pkgs ? import <nixpkgs> { } }:
import ./pkgs {
  inherit pkgs;
  lib = import ./lib { inherit (pkgs) lib; };
}
