{
  lib,
  stdenv,
  gradle_9,
  jdk17,
  jre,
  makeWrapper,
  fetchFromGitHub,
  writeShellApplication,
  nix-update,
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

  # AGP needs a writable ~/.android; inside the update script's bwrap the JVM
  # can't resolve user.home (no passwd entry) and falls back to "?"
  preConfigure = ''
    export ANDROID_USER_HOME="$(mktemp -d)"
  '';

  doCheck = false;

  # bump version/src hash, then regenerate deps.json against the *new* source;
  # mitmCache.updateScript bakes in the src drv, so it must be re-evaluated after the bump
  passthru.updateScript =
    let
      drv = writeShellApplication {
        name = "update-komf";
        runtimeInputs = [ nix-update ];
        text = ''
          attr="''${UPDATE_NIX_ATTR_PATH:-komf}"
          nix-update --flake "$attr" "$@"
          "$(nix build --no-link --print-out-paths ".#$attr.mitmCache.updateScript")"
        '';
      };
    in
    [ "${drv}/bin/update-komf" ];

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
