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
  pkgs,
  lib ? pkgs.lib,
}:
let
  inherit (pkgs) vimUtils fetchFromGitHub nix-update-script;
in
{
  # dashboard = vimUtils.buildVimPlugin {
  #     pname = "dashboard-nvim";
  #     version = "different_shortcuts";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "skyethepinkcat";
  #       repo = "dashboard-nvim";
  #       rev = "0eda18b79813745203a57c1e26a058c2df8b573e";
  #       hash = "sha256-ElzyvHxlbn6zoCvbWZseV2DUIIrChkuXNR1BOeWV+QU=";
  #     };
  #     meta.homepage = "https://github.com/nvimdev/dashboard-nvim/";
  #     meta.hydraPlatforms = [ ];
  #     passthru.updateScript = nix-update-script {
  #       attrPath = "vimPlugins.dashboard";
  #     };
  #   };

  # Add vim plugins here
}
