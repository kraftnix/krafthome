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
    types
    ;
  wcfg = config.khome.desktop.wm;
  cfg = wcfg.niri;
in
{

  options.khome.desktop.wm.niri = {
    cornerRadius = mkOption {
      description = "default corner radius for all windows, ignored if 0";
      default = 12.0;
      type = types.float;
    };
    window-rules = mkOption {
      description = "set of window-rules to add to {programs.niri.settings.window-rules}";
      default = { };
      type = types.attrsOf (types.attrsOf types.raw);
    };
  };

  config = {
    khome.desktop.wm.niri.settings.window-rules = mapAttrsToList (_: w: removeAttrs w [ "enable" ]) (
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
        geometry-corner-radius = mkDefault [
          cfg.cornerRadius
          cfg.cornerRadius
          cfg.cornerRadius
          cfg.cornerRadius
        ];
        clip-to-geometry = mkDefault true;
      };
      firefox-pip = {
        enable = mkDefault cfg.enableDefaults;
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      };
      messengers = {
        enable = mkDefault cfg.enableDefaults;
        matches = [
          { app-id = "fluffychat"; }
          {
            title = "^Element";
            app-id = "electron";
          }
        ];
        open-on-workspace = cfg.workspaces."004-chat".name;
        open-focused = false;
      };
      floating = {
        enable = mkDefault cfg.enableDefaults;
        matches = [
          { app-id = "com.nextcloud.desktopclient.nextcloud"; }
          { title = "alsamixer"; }
          { title = "mpv"; }
          { app-id = "org.pulseaudio.pavucontrol"; }
          {
            app-id = "thunderbird";
            title = "Edit Calendar";
          }
        ];
        open-floating = true;
        open-focused = true;
      };
    };
  };
}
