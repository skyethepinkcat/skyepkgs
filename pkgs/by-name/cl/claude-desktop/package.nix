{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    version1 = "1.5354.0";
    version2 = "9a9e3d5a4a368f0f49a80dc303b0ed1a18bfedad";
  in
  {
    version = "${version1}-${version2}";
    pname = "claude-desktop";
    src = fetchzip {
      url = "https://downloads.claude.ai/releases/darwin/universal/${version1}/Claude-${version2}.zip";
      hash = "sha256-mEObbChAVBFhBnrjn+6tt0cjI3YiKmAqlDO9K/rOprg=";
      stripRoot = false;
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r "Claude.app" $out/Applications/

      runHook postInstall
    '';

    dontBuild = true;
    dontFixup = true;

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "The Official Claude Desktop Application";
      homepage = "https://claude.ai/";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = [ "aarch64-darwin" ];
      license = lib.licenses.unfree;
    };
  }
)
