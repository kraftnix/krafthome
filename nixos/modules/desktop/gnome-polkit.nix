{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.desktop.gnome-polkit;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.khome.desktop.gnome-polkit = {
    enable = mkEnableOption "enable gnome-polkit agent";
  };

  config = mkIf cfg.enable {
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
