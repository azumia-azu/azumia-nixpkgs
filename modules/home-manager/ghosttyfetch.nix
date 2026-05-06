{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.ghosttyfetch;
  jsonFormat = pkgs.formats.json { };

  configFile = jsonFormat.generate "ghosttyfetch-config.json" cfg.settings;
  animationFile =
    if cfg.animation == null then
      "${cfg.package}/share/ghosttyfetch/animation.json"
    else
      jsonFormat.generate "ghosttyfetch-animation.json" cfg.animation;
in
{
  options.programs.ghosttyfetch = {
    enable = lib.mkEnableOption "GhosttyFetch";

    package = lib.mkPackageOption pkgs "ghosttyfetch" { };

    targetDirectory = lib.mkOption {
      type = lib.types.str;
      default = ".config/ghosttyfetch";
      example = ".local/share/ghosttyfetch";
      description = ''
        Directory, relative to the home directory, where config.json and
        animation.json are written.
      '';
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = import ../ghosttyfetch/default-settings.nix;
      example = lib.literalExpression ''
        {
          fps = 20.0;
          color = "#ffffff";
          sysinfo.modules = [ "OS" "Kernel" "Memory" ];
        }
      '';
      description = "Settings written to ghosttyfetch config.json.";
    };

    animation = lib.mkOption {
      type = lib.types.nullOr jsonFormat.type;
      default = null;
      example = lib.literalExpression ''
        {
          frame_count = 1;
          lines_per_frame = 1;
          max_width = 5;
          frames = [ "hello" ];
        }
      '';
      description = ''
        Animation data written to ghosttyfetch animation.json. When null, the
        animation bundled with the selected package is used.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file = {
      "${cfg.targetDirectory}/config.json".source = configFile;
      "${cfg.targetDirectory}/animation.json".source = animationFile;
    };
  };
}
