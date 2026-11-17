{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.sqlmux;
in
{
  options.programs.sqlmux = {
    enable = lib.mkEnableOption "sqlmux";

    package = lib.mkPackageOption pkgs "sqlmux" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
