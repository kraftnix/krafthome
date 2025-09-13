{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    types
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.services.kanshi;
in
{
  options.khome.desktop.services.shikane = {
    enable = opts.enable "enable shikane, a dynamic display configuration service for wayland.";
    profiles = lib.mkOption {
      description = ''
        Display profiles to add to shikane settings.

        Contains a set of outputs.
      '';
      default = { };
      type = types.attrsOf (types.listOf (pkgs.formats.toml { }).type);
      example = lib.literalExpression ''
        {
          external-monitor-default = [
            {
              match = "eDP-1";
              enable = true;
            }
            {
              match = "HDMI-A-1";
              enable = true;
              position = {
                x = 1920;
                y = 0;
              };
            }
          ];
          builtin-monitor-only = [
            {
              match = "eDP-1";
              enable = true;
            }
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    services.shikane = {
      enable = true;
      settings.profile = lib.mapAttrsToList (name: output: {
        inherit name output;
      }) cfg.profiles;
    };
  };
}
