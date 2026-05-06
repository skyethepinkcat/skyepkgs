{
  lib,
  stdenv,
  fetchFromGitHub,
  swift,
  apple-sdk,
bash,
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    version = "3.0.10";
  in
  {
    inherit version;

    pname = "macism";
    src = fetchFromGitHub {
      owner = "laishulu";
      repo = "macism";
      rev = "v${version}";
      hash = "sha256-TNZoVCGbWYZHWL1hgdq9p+RrbsWLtL8FuNpf0OvN+uM=";
    };

    buildInputs = [
      swift
      apple-sdk
    ];

    installFlags = ["SHELL=${lib.getExe bash}"];
    installPhase =
      ''
        runHook preInstall

        mkdir -p $out/bin
        mkdir -p $out/Applications

        mv macism $out/bin
        mv TemporaryWindow $out/bin

        cp -r TemporaryWindow.app $out/Applications

        runHook postInstall
      ''
      ;

    meta = {
      description = "Reliable CLI MacOS Input Source Manager";
      homepage = "https://github.com/laishulu/macism";
      platforms = [ "aarch64-darwin" ];
      license = lib.licenses.mit;
      maintainers = [ lib.maintainers.skyethepinkcat ];
    };
  }
)
