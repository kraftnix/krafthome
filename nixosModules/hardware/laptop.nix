{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.hardware.laptop;
  inherit (lib)
    flatten
    mkEnableOption
    mkIf
    mkMerge
    ;
in
{
  options.khome.hardware.laptop = {
    headless = mkEnableOption "headless laptop mode";
    powersave = mkEnableOption "powersave mode";
    battery-tools = mkEnableOption "add useful tools for battery management";
  };

  config = mkMerge [
    (mkIf cfg.battery-tools {
      environment.systemPackages = flatten (
        with pkgs;
        [
          upower
          acpi
          (lib.optional (config.khome.desktop.enable) gnome-power-manager)
        ]
      );
    })
    (mkIf cfg.headless {
      services.logind.settings.Login = {
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitch = "ignore";
      };
    })
    (mkIf cfg.powersave {
      services.tlp.enable = true;
      powerManagement.cpuFreqGovernor = "powersave";
    })
  ];
}
