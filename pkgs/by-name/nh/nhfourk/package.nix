{
  fetchFromGitHub,
  stdenv,
  sdl2-compat,
zlib,
perl,
}:
stdenv.mkDerivation {
  name = "nhfourk";
  src = fetchFromGitHub {
    owner = "tsadok";
    repo = "nhfourk";
    rev = "479383a";
    hash = "sha256-tfCOFPje9VI4dkJyHTm4InYNePAUsFUfeTszXrUn3BA=";
  };

  nativeBuildInputs = [
    sdl2-compat
    zlib
    perl
  ];
  buildPhase = ''
    runHook preBuild
    mkdir build
    cd build
    ../aimake

    runHook postBuild
  '';
}
