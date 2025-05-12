args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.mako;
  mkIntOption =
    default: description:
    mkOption {
      inherit description default;
      type = types.int;
    };
  mkStrOption =
    default: description:
    mkOption {
      inherit description default;
      type = types.str;
    };
in
{
  options.khome.desktop.mako = {
    enable = mkEnableOption "enable mako integration";
    backgroundColor = mkStrOption "#1a1b26" "background colour";
    borderColor = mkStrOption "#ad8ee6" "border colour";
    progressColor = mkStrOption "over #449dab" "progress colour";
    textColor = mkStrOption "#a9b1d6" "text colour";
    fontSizeStr = mkStrOption "Fira Code Nerd Font Mono 13" "font size string, i.e. Hack 13";
    height = mkIntOption 300 "notification window height";
    width = mkIntOption 600 "notification window width";
    defaultTimeout = mkIntOption 500 "time until screen lock (seconds), default 5mins";
    extraSettings = mkOption {
      description = "extra configuration to add to `services.mako`";
      default = { };
      type = (pkgs.formats.ini { }).lib.types.atom;
    };
  };

  config = mkIf cfg.enable {
    services.mako.enable = true;
    services.mako.settings = mkMerge [
      (mapAttrs (_: mkDefault) {
        inherit (cfg)
          height
          width
          ;
        default-timeout = cfg.defaultTimeout;
        background-color = cfg.backgroundColor;
        text-color = cfg.textColor;
        progress-color = cfg.progressColor;
        border-color = cfg.borderColor;
        anchor = "top-center";
        sort = "-time";
        max-visible = 5;

        # look
        border-size = 5;
        border-radius = 3;
        font = cfg.fontSizeStr;
      })
      cfg.extraSettings
    ];
  };
}
