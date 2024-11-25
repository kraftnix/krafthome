{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.desktop.sddm;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.khome.desktop.sddm = {
    enable = mkEnableOption "enable SDDM as display manager";
    defaultSession = mkOption {
      default = "sway";
      type = types.str;
      description = "default session";
    };
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    services.displayManager.defaultSession = cfg.defaultSession;
    services.displayManager.sddm = {
      enable = true;
      settings = {};
    };
  };
}
