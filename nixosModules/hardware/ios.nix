{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.khome.hardware.ios;
in {
  options.khome.hardware.ios.enable = mkEnableOption "enable ios backup tools";

  config = mkIf cfg.enable {
    # users.users.<user>.extraGroups = [ "usbmux" ];
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [
      libimobiledevice # general tools (backup/restore/info etc.)
      ifuse # (fuser) mount filesystem
      ideviceinstaller # list/modify installed apps
      idevicerestore # restore/upgrade firmware
    ];
  };
}
