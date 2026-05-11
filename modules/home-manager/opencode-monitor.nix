{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.opencode-monitor;
  toml = pkgs.formats.toml { };
in
{
  options.programs.opencode-monitor = {
    enable = lib.mkEnableOption "opencode-monitor";

    package = lib.mkPackageOption pkgs "opencode-monitor" { };

    settings = lib.mkOption {
      inherit (toml) type;
      default = { };
      description = "Configuration written to ~/.config/ocmonitor/config.toml";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."ocmonitor/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = toml.generate "config.toml" cfg.settings;
    };
  };
}
