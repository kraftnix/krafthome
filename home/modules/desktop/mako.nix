args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.mako;
  mkIntOption = default: description:
    mkOption {
      inherit description default;
      type = types.int;
    };
  mkStrOption = default: description:
    mkOption {
      inherit description default;
      type = types.str;
    };
in {
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
    extraConfig = mkOption {
      default = {};
      type = types.raw;
      description = "extra configuration to add to `services.mako`";
    };
  };

  config = mkIf cfg.enable {
    services.mako = mkMerge [
      {
        inherit (cfg) height width defaultTimeout backgroundColor borderColor progressColor textColor;
        enable = true;
        anchor = "top-center";
        sort = "-time";
        maxVisible = 5;

        # look
        borderSize = 5;
        borderRadius = 3;
        font = cfg.fontSizeStr;
      }
      cfg.extraConfig
    ];
  };
}
