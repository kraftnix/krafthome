{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.apps.productivity.logseq;

  inherit (pkgs.lib.khome) toggleApp;
  # swayMain = !config.programs.hyprland.isMain;
  swayMain = true;
in
{
  options.khome.desktop.apps.productivity.logseq = {
    enable = opts.enable "enable logseq";
    sway = opts.enableTrue "enable sway integration (command + keybind)";
    hyprland = opts.enableTrue "enable hyprland integration (specialworkspace + keybind)";
    niri = opts.enableTrue "enable niri integration (named workspace + keybind)";
    niriWorkspace = opts.string "010-logseq" "named workspace to store logseq in";
    waybar = opts.enableTrue "enable waybar workspace rename";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ logseq ];
    wayland.windowManager.sway.config = mkIf cfg.sway {
      window.commands = [
        {
          criteria = {
            app_id = "Logseq";
          };
          #command = "mark logseq, floating enable, move scratchpad";
          command = "mark 11-logseq, move to workspace 11-logseq";
        }
      ];
    };
    programs.waybar = mkIf cfg.waybar {
      settings.mainbar."sway/workspaces".format-icons."11-logseq" = lib.mkIf swayMain "📔";
    };

    khome.desktop.wm.niri.window-rules.logseq =
      mkIf (builtins.hasAttr cfg.niriWorkspace config.khome.desktop.wm.niri.workspaces)
        {
          enable = cfg.niri;
          matches = [
            {
              app-id = "Logseq";
            }
          ];
          open-on-workspace = config.khome.desktop.wm.niri.workspaces."010-logseq".name;
          open-floating = true;
          open-maximized = true;
          default-column-width.proportion = 0.98;
          default-window-height.proportion = 0.96;
        };

    programs.hyprland = mkIf cfg.hyprland {
      windowRules."title:^(Logseq)$" = [
        "workspace special:logseq"
        "animation popin"
        "size 1403 898"
        "move 8 39"
        "float"
      ];
    };

    khome.desktop.wm.shared.binds.logseq = {
      enable = true;
      exec = true;
      mapping = "n";
      sway = {
        enable = cfg.sway;
        exec = false; # toggleApp sets its own exec
        command = toggleApp "11-logseq 'resize set 1912 1043, move position 4 4'";
      };
      hyprland = {
        enable = cfg.hyprland;
        command = "togglespecialworkspace, logseq";
      };
      niri = mkIf cfg.niri {
        enable = true;
        command = mkIf (builtins.hasAttr cfg.niriWorkspace config.khome.desktop.wm.niri.workspaces) (
          "${pkgs.writers.writeNu "focus_logseq.nu" ''
            let matches = (
              niri msg -j windows
              | from json
              | where app_id == Logseq
            )
            if ($matches | length) > 0 {
              let match = ($matches | get 0)
              if $match.is_focused {
                niri msg action move-window-to-workspace ${
                  config.khome.desktop.wm.niri.workspaces.${cfg.niriWorkspace}.name
                } --focus false --window-id $match.id
                if $match.is_floating {
                  niri msg action toggle-window-floating --id $match.id
                }
              } else {
                if not $match.is_floating {
                  niri msg action toggle-window-floating --id $match.id
                }
                nirius move-to-current-workspace -f --app-id Logseq
              }
            } else {
              notify-send "Logseq is not open"
            }
          ''}"
        );
      };
    };
  };
}
