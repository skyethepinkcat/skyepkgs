{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.programs.iterm2-shell-integration;
in
{
  options.programs.iterm2-shell-integration = {
    enable = lib.mkEnableOption "iterm2-shell-integration";

    package = lib.mkPackageOption pkgs "iterm2-shell-integration" { };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    programs = {
   bash.initExtra = mkIf cfg.enableBashIntegration ''
      source ${cfg.package}/share/iterm2-shell-integration/shell-integration.bash
    '';
    zsh.initContent = mkIf cfg.enableZshIntegration ''
      source ${cfg.package}/share/iterm2-shell-integration/shell-integration.zsh
    '';
     fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
       source ${cfg.package}/share/iterm2-shell-integration/shell-integration.fish
     '';
    };
  };
}
