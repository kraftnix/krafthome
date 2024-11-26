{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.sound.bluetooth;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.sound.bluetooth = {
    enable = mkEnableOption "enable bluetooth";
    blueman = mkEnableOption "use blueman as bluetooth manager" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.blueman.enable = cfg.blueman;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };
}
