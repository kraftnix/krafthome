{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mapAttrs mkOptionDefault;
  cfg = config.khome.desktop.wm.sway;
  opts = self.inputs.extra-lib.lib.options;
  inherit (self.lib.khome) toggleApp wrapSwayrLog;
in {
  options.khome.desktop.wm.sway = {
    swayr = {
      enable = opts.enableTrue "enable swayr integration";
      systemd = opts.enableTrue "use systemd user unit";
      settings = opts.raw {} "settings to add to swayr config.toml";
    };
  };

  config = mkIf cfg.swayr.enable {
    programs.swayr = {
      enable = true;
      systemd.enable = cfg.swayr.systemd;
      inherit (cfg.swayr) settings;
    };

    # wayland.windowManager.sway.config = sharedConfig;
    khome.desktop.wm.sway = {
      startup = [
        (
          if cfg.swayr.systemd
          then {
            command = "systemctl --user restart swayrd";
            always = true;
          }
          else {
            command = "exec env RUST_BACKTRACE=1 RUST_LOG=swayr=debug swayrd > /tmp/swayrd.log 2>&1";
          }
        )
      ];

      keybindings = mapAttrs (n: lib.mkOverride 300) {
        "$mod+m" = wrapSwayrLog "execute-swayr-command";
        "$mod+Shift+m" = wrapSwayrLog "execute-swaymsg-command";
        "$mod+a" = wrapSwayrLog "switch-window";
        "$mod+Shift+a" = wrapSwayrLog "switch-workspace-or-window";
        "$mod+Delete" = wrapSwayrLog "quit-window";
        # overrides my default
        "$mod+Shift+Tab" = wrapSwayrLog "switch-to-urgent-or-lru-window";
        "$mod+Ctrl+l" = wrapSwayrLog "next-window all-workspaces";
        "$mod+Ctrl+h" = wrapSwayrLog "prev-window all-workspaces";
      };
    };
  };
}
