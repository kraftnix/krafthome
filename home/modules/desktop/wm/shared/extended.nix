{ self, ... }:
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.khome.desktop.wm;
  opts = self.inputs.extra-lib.lib.options;

  sharedConfig = {
    window = {
      # Hide borders
      hideEdgeBorders = "none";
      titlebar = false;
      border = 2;
      commands = [
        {
          criteria = {
            "urgent" = "latest";
          };
          command = "focus";
        }
        {
          criteria = {
            title = "alsamixer";
          };
          command = "floating enable border pixel 1";
        }
        {
          criteria = {
            app_id = "pulseaudio";
          };
          command = "floating enable border pixel 1";
        }
      ];
    };
    assigns = {
      "2" = [
        { app_id = "Firefox$"; }
      ];
      "3" = [
        { app_id = "Signal"; }
        { app_id = "telegramdesktop"; }
        { app_id = "evolution"; }
      ];
    };
    floating = {
      titlebar = false;
      criteria = [
        {
          title = "Appointment";
          app_id = "evolution";
        }
      ];
    };
  };
  # i3 uses `class` instead of `app_id` for app identification
  criteriaRewrite =
    criteria:
    builtins.removeAttrs (
      criteria
      // {
        class = criteria.app_id;
      }
    ) [ "app_id" ];
in
{
  options.khome.desktop.wm = {
    extended = opts.enableTrue "enable extra opts";
  };

  config = mkIf cfg.extended {
    wayland.windowManager.sway.config = sharedConfig;
    xsession.windowManager.i3.config = sharedConfig // {
      assigns = builtins.mapAttrs (name: builtins.map criteriaRewrite) sharedConfig.assigns;
      floating.criteria = builtins.map criteriaRewrite sharedConfig.floating.criteria;
    };
    khome.desktop.wm = {
      keybindings = {
        "$mod+Shift+f" = "exec pcmanfm";
      };
    };
  };
}
