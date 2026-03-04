# hello-skyepkgs - example package demonstrating the skyepkgs package format.
#
# This package serves as a template showing how to add new packages to
# skyepkgs.  Delete or replace it with your own packages.
{
  lib,
  stdenv,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hello-skyepkgs";
  version = "0.1.0";

  # For a real package you would typically set `src` to a fetchurl/fetchgit
  # derivation.  This trivial example creates its source inline.
  src = builtins.path {
    name = "${finalAttrs.pname}-${finalAttrs.version}-source";
    path = ./.;
    filter = path: type: baseNameOf path == "hello.sh";
  };

  buildInputs = [ bash ];

  # No configure / make needed for this example.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 hello.sh "$out/bin/hello-skyepkgs"
    runHook postInstall
  '';

  meta = lib.skyepkgs.mkMeta {
    description = "Example package for skyepkgs";
    homepage = "https://github.com/skyethepinkcat/skyepkgs";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
