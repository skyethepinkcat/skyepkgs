{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  rev = "2d4b08dcf653d9d63460d40d911bbe7f133bcea3";
in
buildGoModule {
  pname = "goshleep";
  version = "v0.0.1-${rev}";
  src = fetchFromGitHub {
    inherit rev;
    owner = "Secret-Society-Blanket";
    repo = "goshleep";
    hash = "sha256-gAEsFbeNwf+E9D8/CBv7Z1knqUYWFOgnCiyf06GWTxw=";
  };
  vendorHash = "sha256-Gc37J04uw+aDmS2mKtWOJQot2M+nkraH5zaRwJluvs4=";

  meta = {
    description = "Anime gif reaction bot.";
    homepage = "https://github.com/Secret-Society-Blanket/goshleep";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ skyethepinkcat ];
  };
}
