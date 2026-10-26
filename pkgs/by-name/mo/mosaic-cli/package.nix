{
  ffmpeg,
  mediainfo,
  lib,
  stdenv,
  openssl,
  wrapGAppsHook4,
  rustPlatform,
  fetchPnpmDeps,
  pnpm_11,
  pnpmConfigHook,
  glib-networking,
  nodejs,
  cargo-tauri,
  pkg-config,
  webkitgtk_4_1,
  fetchFromGitHub,
  makeWrapper,
}:

let
  pnpm = pnpm_11;

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mosaic";
  version = "0.1.9";
  cargoHash = "sha256-TiTfdsVIspH4zW4Jlc6ays9PM5pmGiBzUDE0whFOGBY=";
  src = fetchFromGitHub {
    owner = "mosaicvideo";
    repo = "mosaic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vxbPl7VOQSbuCR6hSlebBmuxoE/QXbBHvERo6q4ebrg=";
  };
  pnpmDeps = fetchPnpmDeps {
    pname = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    fetcherVersion = 4;
    inherit pnpm;
    inherit (finalAttrs) src;
    hash = "sha256-rYBcAIjWZkYs/Wbz78Vn2cTm2LRZQ1fCj/mQkjYBftQ=";
  };
  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = [
    ffmpeg
    mediainfo
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];
  nativeCheckInputs = [
    ffmpeg
    mediainfo
  ];

  postInstall = ''
    wrapProgram "$out/bin/mosaic-cli" --prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
        mediainfo
      ]
    }
  '';
  # Updater artifacts need TAURI_SIGNING_PRIVATE_KEY; skip them
  tauriBuildFlags = [
    "--config"
    (builtins.toJSON { bundle.createUpdaterArtifacts = false; })
  ];

  cargoRoot = "mosaic-cli";

  buildAndTestSubdir = finalAttrs.cargoRoot;

})
