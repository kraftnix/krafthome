args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionals
    types
    ;
  cfg = config.khome.desktop.misc;
in
{
  options.khome.desktop.misc = {
    enable = mkEnableOption "enable misc integration";
    __allPackages = mkOption {
      default = optionals cfg.enable (
        with pkgs;
        [
          # theme
          hicolor-icon-theme
          font-awesome

          pcmanfm # file manager
          volumeicon # volume tray icon
          brightnessctl # brightness control
          # virt-manager # libvirt gui

          # utility
          zathura # pdf viewer
          imv # image viewer
          mpv # video player
        ]
      );
      type = types.listOf types.package;
      description = "final packages added to `home.packages`";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.__allPackages;
  };
}
