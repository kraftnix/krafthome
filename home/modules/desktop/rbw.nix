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
  imports = [
    (lib.mkAliasOptionModule [ "khome" "desktop" "rbw" "settings" ] [ "programs" "rbw" "settings" ])
  ];

  options.khome.desktop.rbw = {
    enable = opts.enable "enable rbw integration";
    package = opts.package pkgs.rbw "rbw package";
    rofiPackage = opts.package pkgs.rofi-rbw-wayland "rofi package to use";
    keybind = opts.string "p" "hyprland mod key (with $mod + shift)";
    enableShift = opts.enableTrue "add Shift to keybind";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.rofiPackage ];

    programs.rbw = {
      enable = true;
      package = cfg.package;
      settings = {
        lock_timeout = mkDefault (60 * 60 * 24);
        pinentry = mkDefault pkgs.pinentry-gnome3;
      };
    };

    khome.desktop.wm.shared.binds.rbw = {
      enable = true;
      exec = true;
      mapping = cfg.keybind;
      command = "rofi-rbw";
      extraKeys = mkIf cfg.enableShift [ "Shift" ];
    };
  };
}
