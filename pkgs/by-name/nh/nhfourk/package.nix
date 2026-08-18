{
  fetchFromGitHub,
  stdenv,
}:
let
  pkgs = (builtins.getFlake "github:nixos/nixpkgs/nixos-21.11").legacyPackages."${stdenv.system}";
in
pkgs.stdenv.mkDerivation {
  name = "nhfourk";
  src = fetchFromGitHub {
    owner = "tsadok";
    repo = "nhfourk";
    rev = "479383a";
    hash = "sha256-tfCOFPje9VI4dkJyHTm4InYNePAUsFUfeTszXrUn3BA=";
  };

  nativeBuildInputs = with pkgs;[
    SDL2
    zlib
    flex
    bison
    perl
    perl534
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
