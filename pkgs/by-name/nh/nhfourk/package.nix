{
  fetchFromGitHub,
  stdenv,
  SDL2,
  bison,
  zlib,
  flex,
  jansson,
}:
let
  pkgs = (builtins.getFlake "github:nixos/nixpkgs/nixos-22.11").legacyPackages."${stdenv.system}";
in
stdenv.mkDerivation {
  name = "nhfourk";
  hardeningDisable = [ "format" ];
  src = fetchFromGitHub {
    owner = "tsadok";
    repo = "nhfourk";
    rev = "479383a";
    hash = "sha256-tfCOFPje9VI4dkJyHTm4InYNePAUsFUfeTszXrUn3BA=";
  };

  patches = [
    ./patch1.patch
  ];
  nativeBuildInputs = [
    SDL2
    zlib
    flex
    bison
    pkgs.perl
    jansson
  ];
  buildPhase = ''
    runHook preBuild
    mkdir build
    patchShebangs --build aimake scripts/*

    cd build

    ../aimake --without=jansson --without=gui -B fhs
    runHook postBuild
  '';
  installPhase = ''
  runHook preInstall
  cd build
  mkdir -p $out

  ../aimake --without=jansson --without=gui --install-only -B fhs -i $out

  runHook postInstall
  '';
}
