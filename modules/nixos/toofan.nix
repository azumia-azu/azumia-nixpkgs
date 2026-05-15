{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.toofan;
in
{
  options.programs.toofan = {
    enable = lib.mkEnableOption "Toofan";

    package = lib.mkPackageOption pkgs "toofan" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
