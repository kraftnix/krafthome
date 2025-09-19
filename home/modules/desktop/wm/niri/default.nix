args@{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
    ;
  wcfg = config.khome.desktop.wm;
  cfg = wcfg.niri;
  opts = self.inputs.extra-lib.lib.options;
in
{
  imports = [
    ./default-binds.nix
    (import ./window-rules.nix args)
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "wm" "niri" "settings" ]
      [ "programs" "niri" "settings" ]
    )
  ];

  options.khome.desktop.wm.niri = {
    enable = opts.enable "enable niri config";
    enableDefaults = opts.enable "enable (opinionated) defaults";
    importVars = mkOption {
      description = "Environment variables to import into systemd user + dbus";
      default = [
        "WAYLAND_DISPLAY"
        "DISPLAY"
        "DBUS_SESSION_BUS_ADDRESS"
        "NIRI_SOCKET"
        "XDG_SESSION_TYPE"
        "XDG_SESSION_DESKTOP"
        "XDG_CURRENT_DESKTOP"
      ];
      type = types.listOf types.str;
    };
    borderWidth = mkOption {
      description = "global setting for border width";
      default = 4;
      type = types.int;
    };
    workspaces = mkOption {
      description = "workspaces to set in {programs.niri.settings.workspaces}";
      default = {
        "001-term" = {
          name = " ";
        };
        "002-browser" = {
          name = " ";
        };
        "003-alt" = {
          name = " ";
        };
        "004-chat" = {
          name = " ";
        };
        "005" = {
          name = "5";
        };
        "006" = {
          name = "6";
        };
        "007" = {
          name = "7";
        };
        "008" = {
          name = "8";
        };
        "009" = {
          name = "9";
        };
        "010-logseq".name = "📒";
      };
      type = types.attrsOf types.raw;
    };
    opacity = mkOption {
      description = "opacity for windows, default to 1.0 (ignored and noop)";
      default = 1.0;
      type = types.float;
    };
    startup = mkOption {
      description = "startup commands";
      default = [ ];
      type = with types; listOf raw;
    };
    extraPackages = mkOption {
      description = "extra packages required by niri";
      default = with pkgs; [
        nirius # extra window management tool
      ];
      type = with types; listOf package;
    };
    xkb = mkOption {
      description = "xkb options to addd to {programs.niri.settings.inputs.keyboard.xkb}";
      default = { };
      type = types.raw;
      example = lib.literalExpression ''
        {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
        }
      '';
    };
  };

  config = mkMerge [
    {
      programs.niri.settings = {
        debug.deactivate-unfocused-windows = { };
        environment = {
          MOZ_ENABLE_WAYLAND = "1";
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_DESKTOP = "niri";
          GDK_BACKEND = "wayland";
          CLUTTER_BACKEND = "wayland";
        };
        xwayland-satellite = {
          enable = true;
          path = lib.getExe pkgs.xwayland-satellite;
        };
        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true; # issues with transparency
      };
    }
    (mkIf cfg.enable {
      home.packages = cfg.extraPackages;
      # stylix.targets.niri.enable = true;
      khome.desktop.wm.niri.xkb = mkIf cfg.enableDefaults {
        layout = "gb";
        options = "caps:escape";
      };
      programs.niri = {
        enable = true;
        settings = mkMerge [
          {
            input.keyboard.xkb = cfg.xkb;
            workspaces = cfg.workspaces;
          }
          (mkIf cfg.enableDefaults {

            spawn-at-startup = lib.mkBefore [
              {
                command = [ "xwayland-satellite" ];
              }
              {
                command = [ "systemctl --user daemon-reload" ];
              }
              {
                command = [ "systemctl --user import-environment ${lib.concatStringsSep " " cfg.importVars}" ];
              }
              {
                command = [
                  "dbus-update-activation-environment --systemd ${lib.concatStringsSep " " cfg.importVars}"
                ];
              }
              {
                command = [ "niriusd" ];
              }
            ];

            # clipboard.disable-primary = true;
            screenshot-path = "~/xdg/screenshots/%Y-%m-%d %H-%M-%S.png";

            animations = {
              enable = true;
              window-movement.kind.spring = {
                damping-ratio = 1.0;
                stiffness = 1000;
                epsilon = 0.0001;
              };
            };
            cursor = {
              hide-after-inactive-ms = 2000;
              hide-when-typing = true;
            };
            gestures.hot-corners.enable = false;

            input = {
              workspace-auto-back-and-forth = true;
              mouse = {
                accel-profile = "flat";
              };
              touchpad = {
                dwt = true;
                dwtp = true;
              };
            };

            layout = {
              gaps = 10;
              always-center-single-column = true;
              preset-column-widths = [
                { proportion = 0.33333; }
                { proportion = 0.5; }
                { proportion = 0.66667; }
                { proportion = 1.0; }
              ];
              default-column-width = {
                proportion = 1.0;
              };
              border = {
                enable = true;
                width = mkDefault cfg.borderWidth;
                active = mkDefault {
                  color = config.lib.stylix.colors.withHashtag.base0D;
                };
                inactive = mkDefault {
                  color = config.lib.stylix.colors.withHashtag.base03;
                };
                urgent = mkDefault {
                  color = config.lib.stylix.colors.withHashtag.base0F;
                };
              };
              focus-ring = {
                enable = true;
                # width = borderWidth;
                width = 1;
              };
              shadow = {
                # enable = true;
                enable = false;
              };
              tab-indicator = {
                enable = true;
                corner-radius = 12;
              };
            };

          })
        ];
      };
    })
  ];
}
