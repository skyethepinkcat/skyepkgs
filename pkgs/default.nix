# skyepkgs package set
#
# Returns an attribute set of all packages in this repository.
# Each package is a derivation built against the provided `pkgs`.
#
# Usage (with flake):
#   packages = import ./pkgs { inherit pkgs lib; };
#
# Usage (with overlay applied to nixpkgs):
#   pkgs.hello-skyepkgs
{
  pkgs,
  lib ? pkgs.lib,
}:
lib.fix (
  self:
  let
    callPackage = pkgs.lib.callPackageWith (pkgs // self // { inherit lib; });

    vimPlugins = callPackage ./vim-plugins { };

    # Import all packages listed under pkgs/by-name using the two-character
    # prefix convention (same as nixpkgs).  Each package lives at:
    #   pkgs/by-name/<2-char-prefix>/<pname>/default.nix
    byName =
      let
        prefixDirs = builtins.attrNames (builtins.readDir ./by-name);
        packagesForPrefix =
          prefix:
          let
            pkgDirs = builtins.attrNames (builtins.readDir (./by-name + "/${prefix}"));
          in
          builtins.listToAttrs (
            map (pname: {
              name = pname;
              value = callPackage (./by-name + "/${prefix}/${pname}/package.nix") { };
            }) pkgDirs
          );
      in
      builtins.foldl' lib.recursiveUpdate { } (map packagesForPrefix prefixDirs);
  in
  byName // { inherit vimPlugins; }
)
