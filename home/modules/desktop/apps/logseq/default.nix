{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional optionals;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.apps.productivity.logseq;

  inherit (pkgs.lib.khome) toggleApp;
  # swayMain = !config.programs.hyprland.isMain;
  swayMain = true;
in {
  options.khome.desktop.apps.productivity.logseq = {
    enable = opts.enable "enable logseq";
    sway = opts.enableTrue "enable sway integration (command + keybind)";
    waybar = opts.enableTrue "enable waybar workspace rename";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [logseq];
    wayland.windowManager.sway.config = mkIf cfg.sway {
      window.commands = [
        {
          criteria = {app_id = "Logseq";};
          #command = "mark logseq, floating enable, move scratchpad";
          command = "mark 11-logseq, move to workspace 11-logseq";
        }
      ];
      keybindings."$mod+n" = lib.mkOverride 250 (toggleApp "11-logseq 'resize set 1912 1043, move position 4 4'");
    };
    programs.waybar = mkIf cfg.waybar {
      settings.mainbar."sway/workspaces".format-icons."11-logseq" = lib.mkIf swayMain "📔";
    };
  };
}
