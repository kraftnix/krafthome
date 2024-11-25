{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional optionals;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.apps.productivity.etesync;
in {
  options.khome.desktop.apps.productivity.etesync = {
    enable = opts.enable "enable etesync-dav";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      etesync-dav
    ];

    systemd.user.services.etesync-dav = {
      Unit = {
        After = ["network.target"];
        Description = "Etesync-DAV sync service";
      };
      Service = {
        ExecStart = "${pkgs.etesync-dav}/bin/etesync-dav";
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
