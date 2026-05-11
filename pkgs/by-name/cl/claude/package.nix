{
  lib,
  stdenvNoCC,
  fetchzip,
  writeShellApplication,
  curl,
  python3,
  nix-update,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    parts = lib.splitString "," finalAttrs.version;
    version1 = builtins.elemAt parts 0;
    version2 = builtins.elemAt parts 1;
  in
  {
    pname = "claude";
    version = "1.6608.2,ebf1a166e82541b54229aa620d117c60923a939a";

    src = fetchzip {
      url = "https://downloads.claude.ai/releases/darwin/universal/${version1}/Claude-${version2}.zip";
      hash = "sha256-yFNiHsB73vYN1xHN+3P9kDihDckWlnfiiyAyPmIRYM0=";
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

    passthru.updateScript =
      let
        drv = writeShellApplication {
          name = "update-claude";
          runtimeInputs = [
            curl
            python3
            nix-update
          ];
          text = ''
            version=$(curl -fsSL "https://downloads.claude.ai/releases/darwin/universal/RELEASES.json" | python3 -c "
import json, sys, re
data = json.load(sys.stdin)
pattern = re.compile(r'/(\d+(?:\.\d+)+)/Claude[._-]([0-9a-f]+)\.zip', re.I)
versions = []
for release in data.get('releases', []):
    url = (release.get('updateTo') or {}).get('url', "")
    m = pattern.search(url)
    if m:
        versions.append((m.group(1), m.group(2)))
if not versions:
    sys.exit(1)
latest = max(versions, key=lambda x: [int(p) for p in x[0].split('.')])
print(f'{latest[0]},{latest[1]}')
")
            exec nix-update --flake --version "$version" "$@"
          '';
        };
      in
      [ "${drv}/bin/update-claude" ];

    meta = {
      description = "The Official Claude Desktop Application";
      homepage = "https://claude.ai/";
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      platforms = [ "aarch64-darwin" ];
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [ skyethepinkcat ];
    };
  }
)
