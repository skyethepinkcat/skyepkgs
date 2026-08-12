{
  fetchzip,
  lib,
  stdenv,
  libxml2,
  curl,
  gnugrep,
  writeShellApplication,
  nix-update,
}:
stdenv.mkDerivation rec {
  pname = "iterm2";
  version = "3.6.11";
  src =
    let
      underscore_version = builtins.replaceStrings [ "." ] [ "_" ] version;
    in
    fetchzip {
      name = "iTerm2-source";
      sha256 = "sha256-Ei3pe0Ui0/0DQ/5qdFr02msz1uC/XGPhrHKP/MBHDsM=";
      url = "https://iterm2.com/downloads/stable/iTerm2-${underscore_version}.zip";
      stripRoot = false;
    };
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r "iTerm.app" $out/Applications/
    runHook postInstall
  '';
  passthru.updateScript =
    let
      drv = writeShellApplication {
        name = "update-iterm2";
        runtimeInputs = [
          libxml2
          nix-update
        ];
        text = ''
          version=$(xmllint <(curl https://raw.githubusercontent.com/gnachman/iterm2-website/master/source/appcasts/final_modern.xml) --xpath "string(/rss/channel/item/title)" | grep -o -P '\d+\.\d+\.\d+')
          exec nix-update --flake --version "$version" "$@"
        '';
      };
    in
    [ "${drv}/bin/update-iterm2" ];

  meta = {
    description = "An alternative to Apple's Terminal app";
    homepage = "https://iterm2.com";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platform = [ "aarch64-darwin" ];
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ skyethepinkcat ];

  };
}
