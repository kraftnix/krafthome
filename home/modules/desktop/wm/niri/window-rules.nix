args@{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrsToList
    mkDefault
    mkOption
    removeAttrs
    types
    ;
  wcfg = config.khome.desktop.wm;
  cfg = wcfg.niri;
in
{

  options.khome.desktop.wm.niri = {
    cornerRadius = mkOption {
      description = "default corner radius for all windows, ignored if 0";
      default = 0.0;
      type = types.float;
    };
    window-rules = mkOption {
      description = "set of window-rules to add to {programs.niri.settings.window-rules}";
      default = { };
      type = types.attrsOf (types.attrsOf types.raw);
    };
  };

  config = {
    programs.niri.settings.window-rules = mapAttrsToList (_: w: removeAttrs w [ "enable" ]) (
      filterAttrs (_: w: w.enable or true) cfg.window-rules
    );

    khome.desktop.wm.niri.window-rules = {
      transparency-active = {
        enable = mkDefault (cfg.opacity != 1.0);
        matches = [ { is-active = true; } ];
        opacity = cfg.opacity;
      };
      transparency-inactive = {
        enable = mkDefault (cfg.opacity != 1.0);
        matches = [ { is-active = false; } ];
        opacity = cfg.opacity;
      };
      corner-radius = {
        enable = cfg.cornerRadius != 0.0;
        geometry-corner-radius = {
          top-right = cfg.cornerRadius;
          top-left = cfg.cornerRadius;
          bottom-right = cfg.cornerRadius;
          bottom-left = cfg.cornerRadius;
        };
      };
      firefox-pip = {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      };
    };
  };
}
