args:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;
  cfg = config.khome.desktop.swaynotificationcenter;
in
{
  options.khome.desktop.swaynotificationcenter = {
    enable = mkEnableOption "anyrun khome swaynotificationcenter config";
    modKeybind = mkOption {
      default = "";
      description = "keybind to add to hyprland/sway with Mod+{keybind}, empty string to disasble";
      type = types.str;
    };
    modIncludeShift = mkEnableOption "add shift to generated keybind";
    extraConfig = mkOption {
      default = { };
      description = "extra config to add to `programs.anyrun.config`";
      type = types.raw;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ swaynotificationcenter ];
    xdg.configFile."swaync/config.json".text = builtins.toJSON {
      "$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
      timeout-critical = 20;
      timeout = 10;
      timeout-low = 5;
      script-fail-notify = true;
      widgets = [ "mpris" ];
      widget-config.mpris = {
        image-size = 64;
        image-radius = 20;
      };
    };

    programs.hyprland.execOnce.swaync = "swaync";
    programs.hyprland.binds = mkIf (cfg.modKeybind != "") {
      "$mainMod${optionalString cfg.modIncludeShift " SHIFT"}"."${cfg.modKeybind}" =
        "exec, swaync-client -t";
    };

    wayland.windowManager.sway.config = {
      startup = [
        {
          always = true;
          command = "swaync";
        }
      ];
      keybindings = mkIf (cfg.modKeybind != "") {
        "$mod+${optionalString cfg.modIncludeShift "+"}${cfg.modKeybind}" =
          lib.mkOverride 250 "exec swaync-client -t";
      };
    };
  };
}
