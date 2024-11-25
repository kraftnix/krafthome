{self, ...}: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) concatStringsSep mkIf mapAttrs mkOptionDefault;
  cfg = config.khome.desktop.wm.sway;
  opts = self.inputs.extra-lib.lib.options;
  inherit (self.lib.khome) toggleApp wrapSwayrLog;
  variableUpdates = [
    "WAYLAND_DISPLAY"
    "DISPLAY"
    "DBUS_SESSION_BUS_ADDRESS"
    "SWAYSOCK"
    "XDG_SESSION_TYPE"
    "XDG_SESSION_DESKTOP"
    "XDG_CURRENT_DESKTOP"
  ];
in {
  options.khome.desktop.wm.sway = {
    full = opts.enableTrue "enable full default config";
  };

  config = mkIf cfg.full {
    khome.desktop.swaynotificationcenter = {
      enable = true;
      modKeybind = "grave"; # backtick
    };

    # wayland.windowManager.sway.config = sharedConfig;
    khome.desktop.wm.sway = {
      swayr.enable = true;
      swaylock.enable = true;
      startup = [
        {
          command = "systemctl --user daemon-reload";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd ${concatStringsSep " " variableUpdates}";
          always = true;
        }
        (
          mkIf (config.programs.eww-hyprland.enable)
          (
            if config.programs.eww-hyprland.systemd
            then {
              command = "systemctl --user reload eww";
              always = true;
            }
            else {
              command = "exec eww daemon";
            }
          )
        )
        (mkIf (config.services.mako.enable) {
          command = "exec mako";
          always = true;
        })
        (
          mkIf (config.programs.waybar.enable && config.programs.waybar.systemd.enable)
          {
            command = "systemctl --user restart waybar";
            always = true;
          }
        )
        (mkIf (config.services.kanshi.enable) {
          command = "systemctl --user restart kanshi";
          always = true;
        })
      ];

      keybindings = mapAttrs (n: mkOptionDefault) {
        # screenshot
        Print = "exec flameshot gui";
        "$mod+Print" = "exec grimshot copy area";
        "$mod+Shift+Print" = "exec grimshot save screen";
        "$mod+Shift+n" = "move scratchpad, scratchpad show, resize set 1912 1043, move position 4 4";
        "$mod+g" = "exec rofi -show emoji -modi emoji ";
        # "$mod+d" = "exec fuzzel --show-actions";
        # "$mod+Shift+d" = ''exec "rofi -show-icons -modi ssh,drun,filebrowser,emoji -show drun"'';

        "$mod+Shift+d" = "exec eww open system-menu --toggle";
        "$mod+Shift+r" = "exec ${pkgs.writeScript "reload_eww" ''
          eww close bar
          swaymsg reload
          eww reload
          eww open bar
        ''}";

        "$mod+a" = wrapSwayrLog "switch-window";
        "$mod+Shift+a" = wrapSwayrLog "switch-workspace-or-window";

        "$mod+period" = "workspace next";
        "$mod+comma" = "workspace prev";
      };
    };
  };
}
