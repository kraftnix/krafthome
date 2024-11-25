{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.khome.hardware.laptop;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;
in {
  options.khome.hardware.laptop = {
    headless = mkEnableOption "headless laptop mode";
    powersave = mkEnableOption "powersave mode";
  };

  config = mkMerge [
    (mkIf cfg.headless {
      services.logind = {
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
      };
    })
    (mkIf cfg.powersave {
      services.tlp.enable = true;
      powerManagement.cpuFreqGovernor = "powersave";
    })
  ];
}
