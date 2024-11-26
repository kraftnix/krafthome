{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.rbw;
in
{
  options.khome.desktop.rbw = {
    enable = opts.enable "enable rbw integration";
    enableHyprlandKeybind = opts.enableTrue "enable hyprland keybinding";
    enableSwayKeybind = opts.enableTrue "enable sway keybinding";
    package = opts.package pkgs.rbw "rbw package";
    rofiPackage = opts.package pkgs.rofi-rbw-wayland "rofi package to use";
    hyprlandKey = opts.string "P" "hyprland mod key (with $mod + shift)";
    swayKey = opts.string "$mod+Shift+p" "sway mod key (with $mod + shift)";
    settings = mkOption {
      type = (pkgs.formats.json { }).type;
      default = {
        # base_url = "https://bitwarden.home.internal";
        # email = "myuser@email.com";
      };
      description = "settings to passthrough";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.rofiPackage ];

    programs.rbw = {
      enable = true;
      package = cfg.package;
      settings = mkMerge [
        cfg.settings
        {
          lock_timeout = mkDefault (60 * 60 * 24);
          pinentry = mkDefault pkgs.pinentry.gnome3;
        }
      ];
    };

    programs.hyprland = mkIf (cfg.enableHyprlandKeybind) {
      binds."$mainMod SHIFT"."${cfg.hyprlandKey}" = "exec, rofi-rbw";
    };

    wayland.windowManager.sway.config.keybindings = mkIf (cfg.enableSwayKeybind) {
      "${cfg.swayKey}" = lib.mkOverride 250 "exec rofi-rbw";
    };
  };
}
