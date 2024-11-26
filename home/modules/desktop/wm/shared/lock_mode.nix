{ self, ... }:
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkBefore;
  cfg = config.khome.desktop.wm;
  opts = self.inputs.extra-lib.lib.options;
in
{
  options.khome.desktop.wm = {
    modes.lock = {
      enable = opts.enableTrue "enable extra opts";
      key = opts.string "$mod+0" "key to open lock mode";
    };
  };

  config = mkIf cfg.extended {
    wayland.windowManager.sway = {
      extraConfigEarly = ''
        set $mode_system (l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown
      '';
      config = {
        keybindings = mkIf cfg.modes.lock.enable {
          ${cfg.modes.lock.key} = "mode \"$mode_system\"";
        };
        modes."$mode_system" = {
          l = ''exec --no-startup-id swaylock -fF, mode "default"'';
          s = ''exec --no-startup-id swaylock -fF && systemctl suspend, mode "default"'';
          u = ''exec --no-startup-id swaymsg switch_user, mode "default"'';
          e = ''exec --no-startup-id swaymsg exit, mode "default"'';
          h = ''exec --no-startup-id swaylock -fF && systemctl hibernate, mode "default"'';
          r = ''exec --no-startup-id systemctl reboot, mode "default"'';
          "Shift+s" = ''exec --no-startup-id systemctl poweroff, mode "default"'';

          # exit system mode: "Enter" or "Escape"
          Return = ''mode "default"'';
          Escape = ''mode "default"'';
        };
      };
    };

    xsession.windowManager.i3 = {
      extraConfig = mkBefore ''
        set $mode_system (l)ock, (e)xit, switch_(u)ser, (s)uspend, (h)ibernate, (r)eboot, (Shift+s)hutdown
      '';
      config = {
        keybindings = mkIf cfg.modes.lock.enable {
          ${cfg.modes.lock.key} = "mode \"$mode_system\"";
        };
        modes."$mode_system" = {
          l = ''exec --no-startup-id i3exit lock, mode "default"'';
          s = ''exec --no-startup-id i3exit suspend && systemctl suspend, mode "default"'';
          u = ''exec --no-startup-id i3exit switch_user, mode "default"'';
          e = ''exec --no-startup-id i3exit logout, mode "default"'';
          h = ''exec --no-startup-id i3exit hibernate && systemctl hibernate, mode "default"'';
          r = ''exec --no-startup-id systemctl reboot, mode "default"'';

          "Shift+s" = ''exec --no-startup-id systemctl poweroff, mode "default"'';

          # exit system mode: "Enter" or "Escape"
          Return = ''mode "default"'';
          Escape = ''mode "default"'';
        };
      };
    };
  };
}
