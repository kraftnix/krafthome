{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.desktop.hyprland;
  hcfg = config.programs.hyprland;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  options.khome.desktop.hyprland = {
    enable = mkEnableOption "enable basic hyprland system-level setup";
  };

  config = mkIf cfg.enable {
    security.pam.services.swaylock.text = "auth include login";
    environment.systemPackages = with pkgs; [
      grim
      slurp
      wlr-randr
      xorg.xprop

      hcfg.package # add final hyprland package to system level
    ];

    # nixos module breaks hyprland due to upstream differences
    # programs.hyprland.enable = true;
    programs.hyprland.enable = lib.mkForce false;
    hardware.graphics.enable = true;

    programs = {
      dconf.enable = true;
      xwayland.enable = hcfg.xwayland.enable;
    };
    security.polkit.enable = true;
    services.displayManager.sessionPackages = [hcfg.package];

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      wlr.enable = true;
      wlr.settings.screencast = {
        # output_name = "HDMI-A-1";
        max_fps = 30;
        # exec_before = "disable_notifications.sh";
        # exec_after = "enable_notifications.sh";
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
  };
}
