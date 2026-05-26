# skyepkgs vim plugins
#
# Custom vim/neovim plugins built with vimUtils.buildVimPlugin.
# These are exposed under pkgs.vimPlugins.<name> (merged with nixpkgs vimPlugins).
#
# To add a plugin:
#   my-plugin = vimUtils.buildVimPlugin {
#     pname = "my-plugin";
#     version = "...";
#     src = fetchFromGitHub { ... };
#   };
{
  lib,
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:
let
  version = "1.2.0";
in
{

  colortils-nvim = vimUtils.buildVimPlugin {
    pname = "colortils-nvim";
    name = "colortils.nvim";
    inherit version;
    src = fetchFromGitHub {
      owner = "max397574";
      repo = "colortils.nvim";
      rev = "v${version}";
      sha256 = "03lj24zm48rc7rj69j2z3345k7frrzvn6jqr51d34adkv682180r";
    };
    meta = {
      homepage = "https://github.com/max397574/colortils.nvim";
      maintainers = with lib.maintainers; [ skyethepinkcat ];
    };
    passthru.updateScript = nix-update-script {
      attrPath = "vimPlugins.colortils-nvim";
    };
  };

  dashboard-nvim = vimUtils.buildVimPlugin {
    pname = "dashboard-nvim";
    version = "0-unstable-2026-04-17-1";
    src = fetchFromGitHub {
      owner = "skyethepinkcat";
      repo = "dashboard-nvim";
      rev = "fbfada3";
      hash = "sha256-5y+hK6ZlnwzCxfDaWDMwl1fljgWjFUGAF2iZo0Zc508=";
    };
    meta = {
      meta = {
        homepage = "https://github.com/nvimdev/dashboard-nvim/";
      };
      license = "MIT";
      hydraPlatforms = [ ];
    };
  };

  # Add vim plugins here
}
