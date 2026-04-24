{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "snip";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "edouard-claude";
    repo = "snip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pRYxTHNdR2NGiE+RdThcmz3zVP5rKVRbt+IEILIgavk=";
  };

  subPackages = [ "cmd/snip" ];

  vendorHash = "sha256-2MxFZqjNuLzcuu+bsLyOyHIakCxh7j0FUx8LsjZRhrY=";

  meta =
    lib.skyepkgs.mkMeta {
      description = "AI-powered CLI snippet manager";
      homepage = "https://github.com/edouard-claude/snip";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    }
    // {
      mainProgram = "snip";
    };
})
