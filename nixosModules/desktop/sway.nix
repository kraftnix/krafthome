{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.desktop.sway;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.desktop.sway = {
    enable = mkEnableOption "enable Sway core system level config";
    polkitAgent = mkOption {
      description = "which polkit agent to use with sway";
      default = "gnome";
      type = types.enum [
        "none"
        "gnome"
      ];
    };
  };

  config = mkIf cfg.enable {
    khome.desktop.gnome-polkit.enable = cfg.polkitAgent == "gnome";
    security.pam.services.swaylock.text = "auth include login";
    environment.systemPackages = with pkgs; [
      grim
      slurp
      swappy
    ];
    programs.sway.enable = true;
    programs.sway.extraSessionCommands = ''
      dbus-update-activation-environment --systemd DISPLAY SWAYSOCK WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIXOS_OZONE_WL
    '';
    xdg.portal = {
      enable = true;
      config.sway.default = "wlr";
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

    services.displayManager.sessionPackages = lib.mkIf config.services.displayManager.gdm.enable [
      config.programs.sway.package
    ];
  };
}
