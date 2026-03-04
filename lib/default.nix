# skyepkgs lib - custom library functions
#
# Usage:
#   lib = import ./lib { inherit (nixpkgs) lib; };
#
# This extends nixpkgs lib with additional utilities specific to skyepkgs.
{ lib }:

lib.extend (
  final: prev: {
    skyepkgs = {
      # Public helper for package authors: returns true if the given package
      # name is a valid non-empty string.  Useful in assertions or tests.
      isValidPackageName = name: builtins.isString name && name != "";

      # Public helper for package authors: deep-merges a list of package-set
      # attrsets into one.  Each attribute set in `pkgSets` is merged; later
      # sets take precedence.  Useful when composing multiple package groups.
      mergePackageSets = pkgSets: builtins.foldl' prev.recursiveUpdate { } pkgSets;

      # Generate package metadata attrset for use in `meta` blocks.
      # Example:
      #   meta = lib.skyepkgs.mkMeta {
      #     description = "My tool";
      #     homepage = "https://example.com";
      #   };
      mkMeta =
        {
          description ? "",
          homepage ? "",
          license ? prev.licenses.mit,
          maintainers ? [ ],
          platforms ? prev.platforms.all,
        }:
        {
          inherit
            description
            homepage
            license
            maintainers
            platforms
            ;
        };
    };
  }
)
