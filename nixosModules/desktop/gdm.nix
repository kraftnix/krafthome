{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.desktop.gdm;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.desktop.gdm = {
    enable = mkEnableOption "enable GDM as display manager";
    defaultSession = mkOption {
      default = "sway";
      type = types.str;
      description = "default session";
    };
  };

  config = mkIf cfg.enable {
    # NOTE: not working
    programs.dconf.enable = true;
    services.displayManager = {
      enable = true;
      defaultSession = "sway";
    };
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
        # sessionPackages = [ config.programs.sway.package ];
        settings = { };
      };
    };
  };
}
