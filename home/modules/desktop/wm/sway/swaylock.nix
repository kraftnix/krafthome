{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkOption;
  cfg = config.khome.desktop.wm.sway;
  opts = self.inputs.extra-lib.lib.options;
  inherit (self.lib.khome) toggleApp wrapSwayrLog;
in {
  options.khome.desktop.wm.sway.swaylock = {
    enable = opts.enableTrue "enable swaylock integration";
    screensaver = mkOption {
      default = config.khome.themes.images.screensaver;
      description = "path to screensaver image";
    };
  };

  config = mkIf cfg.swaylock.enable {
    stylix.targets.swaylock.enable = config.khome.themes.stylix.enable;
    programs.swaylock = {
      enable = true;
      settings = {
        show-failed-attempts = true;
        daemonize = true;
        show-keyboard-layout = true;
        image = "${cfg.swaylock.screensaver}";
      };
    };
  };
}
