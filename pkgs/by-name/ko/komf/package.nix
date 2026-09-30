{
  lib,
  stdenv,
  gradle_9,
  jdk17,
  jre,
  makeWrapper,
  fetchFromGitHub,
}:
let
  gradle = gradle_9.override { java = jdk17; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "komf";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Snd-R";
    repo = "komf";
    tag = finalAttrs.version;
    hash = "sha256-1RmgZkFgcieeLPuYelzvIMfijQXZju2he+ZRSuoGynQ=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  # required for mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;

  gradleBuildTask = ":komf-app:shadowJar";
  # default nixDownloadDeps resolves the Android variants too, which need an SDK
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm644 komf-app/build/libs/komf-app-*-all.jar $out/share/komf/komf.jar
    makeWrapper ${lib.getExe jre} $out/bin/komf \
      --add-flags "-jar $out/share/komf/komf.jar"

    runHook postInstall
  '';

  meta = {
    description = "Komga and Kavita metadata fetcher";
    homepage = "https://github.com/Snd-R/komf";
    license = lib.licenses.mit;
    mainProgram = "komf";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})
