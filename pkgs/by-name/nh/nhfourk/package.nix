{
  fetchFromGitHub,
  stdenv,
  SDL2,
  bison,
  zlib,
  flex,
}:
let
  pkgs = (builtins.getFlake "github:nixos/nixpkgs/nixos-22.11").legacyPackages."${stdenv.system}";
in
pkgs.stdenv.mkDerivation {
  name = "nhfourk";
  src = fetchFromGitHub {
    owner = "tsadok";
    repo = "nhfourk";
    rev = "479383a";
    hash = "sha256-tfCOFPje9VI4dkJyHTm4InYNePAUsFUfeTszXrUn3BA=";
  };

  nativeBuildInputs = [
    pkgs.SDL2
    pkgs.zlib
   pkgs.flex
   pkgs.bison
    pkgs.perl
  ];
  buildPhase = ''
    runHook preBuild
    mkdir build
    patchShebangs --build aimake scripts/*

    cd build
    ../aimake

    runHook postBuild
  '';
}
