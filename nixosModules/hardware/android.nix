{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.hardware.android;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.khome.hardware.android = {
    enable = mkEnableOption "enable adb + udev rules";
  };
  config = mkIf cfg.enable {
    programs.adb.enable = true;
    services.udev.packages = with pkgs; [ android-udev-rules ];
  };
}
