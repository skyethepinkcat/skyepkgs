{
  callPackage,
  fetchFromGitHub,
  pkgs,
  cataclysm-dda,
  tiles ? false,
  debug ? false,
  useXdgDir ? false,
}:

let
  self = (cataclysm-dda.override { inherit tiles debug useXdgDir; }).overrideAttrs (prev: rec {
    # 0.I is the latest stable release tag (https://github.com/CleverRaven/Cataclysm-DDA/releases/tag/0.I)
    version = "1.0-2026-10-21-0831";

    src = fetchFromGitHub {
      owner = "Cataclysm-TLG";
      repo = "Cataclysm-TLG";
      tag = "cataclysm-tlg-${version}";
      hash = "sha256-YUMZSweQHbPUi14HnJDZmRf31XP0ed/U/ZQrImNphl4=";
    };

    meta = prev.meta // {
      changelog = "https://github.com/Cataclysm-TLG/Cataclysm-TLG/blob/${version}/data/changelog.txt";
    };
  });
in

self
