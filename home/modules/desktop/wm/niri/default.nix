args@{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  wcfg = config.khome.desktop.wm;
  cfg = wcfg.niri;
  opts = self.inputs.extra-lib.lib.options;
  niriNull = _: { };
in
{
  imports = [
    ./default-binds.nix
    ./window-rules.nix
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "wm" "niri" "settings" ]
      [ "wrappers" "niri-kraft" "settings" ]
    )
    # NOTE: I hate having to name this as niri-kraft, but it is impossible
    #       to get nix-wrapper-modules to not override the niri systemd service
    #       and doesn't allow me to have niri use ~/.config/niri/config.kdl
    (self.inputs.wrappers.lib.mkInstallModule {
      name = "niri-kraft";
      value = self.inputs.wrappers.lib.wrapperModules.niri;
      loc = [
        "home"
        "packages"
      ];
    })
  ];

  options.khome.desktop.wm.niri = {
    enable = opts.enable "enable niri config";
    enableDefaults = opts.enable "enable (opinionated) defaults";
    xwayland = opts.enable "enable xwayland via xwayland-satellite";
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
      description = ''
        Startup commands to add to niri startup.

        Each command is ordered into a list, `order` defaults to 100.
      '';
      default = { };
      type = types.attrsOf (
        types.submodule (
          { config, name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "enable startup command" // {
                default = true;
              };
              order = lib.mkOption {
                description = "order of command at startup";
                default = 100;
                type = types.int;
                example = 10;
              };
              command = mkOption {
                description = "command to run at startup, defaults to attr name";
                default = name;
                type = types.str;
                example = "systemctl --user restart awww";
              };
            };
          }
        )
      );
    };
    extraPackages = mkOption {
      description = "extra packages required by niri";
      default = [ ];
      type = with types; listOf package;
    };
    xkb = mkOption {
      description = "xkb options to addd to {programs.niri.settings.inputs.keyboard.xkb}";
      default = { };
      type = types.raw;
      example = lib.literalExpression ''
        {
          layout = "gb";
          options = "caps:escape";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."niri/config.kdl".source =
      config.wrappers.niri-kraft.constructFiles.generatedConfig.outPath;

    home.packages = cfg.extraPackages;
    # stylix.targets.niri.enable = true;
    khome.desktop.wm.niri.extraPackages = [
      pkgs.nirius
      pkgs.fuzzel
    ];
    khome.desktop.wm.niri.startup = {
      xwayland-satellite = {
        enable = cfg.xwayland;
        order = 20;
      };
      systemd-daemon-reload = {
        enable = true;
        order = 10;
        command = "systemctl --user daemon-reload";
      };
      systemd-import-environment = {
        enable = true;
        order = 10;
        command = "systemctl --user import-environment ${lib.concatStringsSep " " cfg.importVars}";
      };
      dbus-update-environment = {
        enable = true;
        order = 10;
        command = "dbus-update-activation-environment --systemd ${lib.concatStringsSep " " cfg.importVars}";
      };
      nirius = {
        enable = true;
        command = "niriusd";
        order = 50;
      };
    };
    khome.desktop.wm.niri.xkb = mkIf cfg.enableDefaults {
      layout = "gb";
      options = "caps:escape";
    };
    wrappers.niri-kraft = {
      enable = true;
      v2-settings = true;
      settings = mkMerge [
        {
          debug.deactivate-unfocused-windows = { };
          environment = {
            MOZ_ENABLE_WAYLAND = "1";
            XDG_CURRENT_DESKTOP = "niri";
            XDG_SESSION_DESKTOP = "niri";
            GDK_BACKEND = "wayland";
            CLUTTER_BACKEND = "wayland";
          };
          hotkey-overlay.skip-at-startup = true;
          prefer-no-csd = true; # issues with transparency
        }
        (
          if cfg.xwayland then
            {
              xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
            }
          else
            {
              xwayland-satellite.off = niriNull;
            }
        )
        {
          input.keyboard.xkb = cfg.xkb;
          spawn-at-startup = lib.pipe cfg.startup [
            (lib.filterAttrs (_: s: s.enable))
            lib.attrValues
            (lib.sort (a: b: a.order < b.order))
            (lib.map (s: lib.singleton s.command))
          ];
        }
        (mkIf cfg.enableDefaults {
          # clipboard.disable-primary = true;
          screenshot-path = "~/xdg/screenshots/%Y-%m-%d %H-%M-%S.png";

          # NOTE: workspaces must be added here since otherwise we can't enforce ordering
          extraConfig = lib.concatStringsSep "\n" (
            lib.mapAttrsToList (_: c: "workspace \"${c.name}\"") cfg.workspaces
          );

          animations = {
            window-movement.spring = _: {
              props = {
                damping-ratio = 1.0;
                stiffness = 1000;
                epsilon = 0.0001;
              };
            };
          };
          cursor = {
            hide-after-inactive-ms = lib.mkDefault 2000;
            hide-when-typing = niriNull;
          };
          gestures.hot-corners = { };

          input = {
            workspace-auto-back-and-forth = _: { };
            mouse.accel-profile = "flat";
            touchpad = {
              tap = niriNull;
              natural-scroll = niriNull;
              dwt = niriNull;
              dwtp = niriNull;
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
            default-column-width.proportion = 1.0;
            border = {
              width = cfg.borderWidth;
              active-color = config.lib.stylix.colors.withHashtag.base0D;
              inactive-color = config.lib.stylix.colors.withHashtag.base03;
              urgent-color = config.lib.stylix.colors.withHashtag.base0F;
            };
            focus-ring = {
              on = niriNull;
              # width = borderWidth;
              width = 1;
            };
            shadow = {
              # enable = true;
              off = niriNull;
            };
            tab-indicator = {
              on = niriNull;
              corner-radius = 12;
            };
          };

        })
      ];
    };
  };
}
