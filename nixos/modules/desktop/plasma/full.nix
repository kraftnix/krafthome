{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.desktop.plasma;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.khome.desktop.plasma = {
    enable = mkEnableOption "enable Plasma as default desktop environment";
    defaultSession = mkOption {
      default = "plasma";
      type = types.str;
      description = "default session";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      enable = true;
      inherit (cfg) defaultSession;
      sddm = {
        enable = mkDefault true;
        settings = mkDefault {
          #AutoLogin = {
          #  User = "media";
          #  Session = "plasma.desktop";
          #};
        };
      };
    };
    services.xserver.desktopManager.plasma5.enable = true;
  };
}
