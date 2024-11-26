{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (inputs.provision.lib.attrs) recursiveMerge;
  cfg = config.programs.wayfire;
  iniFormat = pkgs.formats.ini { };
  mkBinding =
    name:
    {
      binding ? null,
      command ? null,
      repeatable ? false,
    }:
    (optionalAttrs (command != null) {
      "command_${name}" = command;
    })
    // (optionalAttrs (binding != null) {
      "${optionalString repeatable "repeatable_"}binding_${name}" = binding;
    });
  defaultBindings = {
    terminal = {
      binding = "<super> KEY_ENTER";
      command = "alacritty";
    };
    launcher = {
      binding = "<super> KEY_D";
      command = "wofi";
    };
    lock = {
      binding = "<super> <shift> KEY_ESC";
      command = "swaylock";
    };
    logout = {
      binding = "<super> KEY_ESC";
      command = "wlogout";
    };
    screenshot = {
      binding = "KEY_PRINT";
      command = "grim $(date '+%F_%T').webp";
    };
    screenshot_interactive = {
      binding = "<shift> KEY_PRINT";
      command = "slurp | grim -g - $(date '+%F_%T').webp";
    };
    # Sound / Volume controls
    volume_up = {
      binding = "KEY_VOLUMEUP";
      command = "amixer set Master 5%+";
      repeatable = true;
    };
    volume_down = {
      binding = "KEY_VOLUMEDOWN";
      command = "amixer set Master 5%-";
      repeatable = true;
    };
    mute = {
      binding = "KEY_MUTE";
      command = "amixer set Master toggle";
    };
    # Screen brightness
    light_up = {
      binding = "KEY_BRIGHTNESSUP";
      command = "light -A 5";
      repeatable = true;
    };
    light_down = {
      binding = "KEY_BRIGHTNESSDOWN";
      command = "light -U 5";
      repeatable = true;
    };
  };
  defaults = {
    autostart = {
      autostart_wf_shell = "false";
      background = "wf-background";
      bar = "waybar";
      outputs = "kanshi";
      notifications = "mako";
      gamma = "wlsunset";
      idle = "swayidle before-sleep swaylock";
      portal = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr";
    };
    core = {
      # Close focused window.
      close_top_view = "<super> KEY_Q | <alt> KEY_F4";

      # Workspaces arranged into a grid: 3 × 3.
      vwidth = 3;
      vheight = 3;

      # Prefer client-side decoration or server-side decoration
      preferred_decoration_mode = "client";
    };
    ## Mouse Options
    # Drag windows by holding down Super and left mouse button.
    move = {
      activate = "<super> BTN_LEFT";
    };

    # Resize them with right mouse button + Super.
    resize = {
      activate = "<super> BTN_RIGHT";
    };

    # Zoom in the desktop by scrolling + Super.
    zoom = {
      modifier = "<super>";
    };

    # Change opacity by scrolling with Super + Alt.
    alpha = {
      modifier = "<super> <alt>";
    };

    # Rotate windows with the mouse.
    wrot = {
      activate = "<super> <ctrl> BTN_RIGHT";
    };

    # Fisheye effect.
    fisheye = {
      toggle = "<super> <ctrl> KEY_F";
    };

    # Position the windows in certain regions of the output.
    grid = {
      #
      # ⇱ ↑ ⇲   │ 7 8 9
      # ← f →   │ 4 5 6
      # ⇱ ↓ ⇲ d │ 1 2 3 0
      # ‾   ‾
      slot_bl = "<super> KEY_KP1";
      slot_b = "<super> KEY_KP2";
      slot_br = "<super> KEY_KP3";
      slot_l = "<super> KEY_LEFT | <super> KEY_KP4";
      slot_c = "<super> KEY_UP | <super> KEY_KP5";
      slot_r = "<super> KEY_RIGHT | <super> KEY_KP6";
      slot_tl = "<super> KEY_KP7";
      slot_t = "<super> KEY_KP8";
      slot_tr = "<super> KEY_KP9";
      # Restore default.
      restore = "<super> KEY_DOWN | <super> KEY_KP0";
    };

    # Change active window with an animation.
    switcher = {
      next_view = "<alt> KEY_TAB";
      prev_view = "<alt> <shift> KEY_TAB";
    };

    # Simple active window switcher.
    fast-switcher = {
      activate = "<alt> KEY_ESC";
    };

    # Workspaces ───────────────────────────────────────────────────────────────────
    # Switch to workspace.
    vswitch = {
      binding_left = "<ctrl> <super> KEY_LEFT | <ctrl> <super> KEY_H";
      binding_down = "<ctrl> <super> KEY_DOWN | <ctrl> <super> KEY_J";
      binding_up = "<ctrl> <super> KEY_UP | <ctrl> <super> KEY_K";
      binding_right = "<ctrl> <super> KEY_RIGHT | <ctrl> <super> KEY_L";
      # Move the focused window with the same key-bindings, but add Shift.
      with_win_left = "<ctrl> <super> <shift> KEY_LEFT | <ctrl> <super> <shift> KEY_H";
      with_win_down = "<ctrl> <super> <shift> KEY_DOWN | <ctrl> <super> <shift> KEY_J";
      with_win_up = "<ctrl> <super> <shift> KEY_UP | <ctrl> <super> <shift> KEY_K";
      with_win_right = "<ctrl> <super> <shift> KEY_RIGHT | <ctrl> <super> <shift> KEY_L";
    };

    # Show the current workspace row as a cube.
    cube = {
      activate = "<ctrl> <alt> BTN_LEFT";
      # Switch to the next or previous workspace.
      rotate_left = "<super> <ctrl> KEY_H";
      rotate_right = "<super> <ctrl> KEY_L";
    };

    # Show an overview of all workspaces.
    expo = {
      toggle = "<super>";
      # Select a workspace.
      # Workspaces are arranged into a grid of 3 × 3.
      # The numbering is left to right, line by line.
      #
      # ⇱ k ⇲
      # h ⏎ l
      # ⇱ j ⇲
      # ‾   ‾
      # See core.vwidth and core.vheight for configuring the grid.
      select_workspace_1 = "KEY_1";
      select_workspace_2 = "KEY_2";
      select_workspace_3 = "KEY_3";
      select_workspace_4 = "KEY_4";
      select_workspace_5 = "KEY_5";
      select_workspace_6 = "KEY_6";
      select_workspace_7 = "KEY_7";
      select_workspace_8 = "KEY_8";
      select_workspace_9 = "KEY_9";
    };

    # Outputs ──────────────────────────────────────────────────────────────────────
    # Change focused output.
    oswitch = {
      # Switch to the next output.
      next_output = "<super> KEY_O";
      # Same with the window.
      next_output_with_win = "<super> <shift> KEY_O";
    };

    # Invert the colors of the whole output.
    invert = {
      toggle = "<super> KEY_I";
    };
  };
  genBinding = bindings: recursiveMerge (attrValues (mapAttrs mkBinding bindings));
  configFilePath = "${config.xdg.configHome}/wayfire.conf";
in
{
  options.programs.wayfire =
    with types;
    mkOption {
      default = { };
      description = "Wayfire Window Manager Options.";
      type = submodule (
        { config, ... }:
        {
          options = {
            enable = mkEnableOption "";
            package = mkOption {
              type = package;
              default = pkgs.wayfire;
              description = "wayfire package";
            };
            plugins = mkOption {
              description = "default / core plugins";
              type = listOf str;
              default = [
                "alpha"
                "animate"
                "autostart"
                "command"
                "cube"
                #"decoration"
                "expo"
                "fast-switcher"
                "fisheye"
                "grid"
                "idle"
                "invert"
                "move"
                "oswitch"
                "place"
                "resize"
                "switcher"
                "vswitch"
                "window-rules"
                "wobbly"
                "wrot"
                "zoom"
              ];
            };
            extraPlugins = mkOption {
              description = "additional plugins outside of core set";
              type = listOf str;
              default = [ ];
              apply =
                extra:
                lib.unique (flatten [
                  config.plugins
                  extra
                ]);
              example = [ "blur" ];
            };
            bindings = mkOption {
              description = "additional key bindings";
              type = attrsOf attrs;
              default = { };
              example = {
                launcher.command = "rofi -show drun";
                custom = {
                  command = "myprogram --with-args";
                  binding = "<super> KEY_T";
                  repeatable = true;
                };
              };
              # NOTE: default key bindings are not removeable
              #       but are overridable
              apply =
                bindings:
                recursiveMerge [
                  (genBinding defaultBindings)
                  (genBinding bindings)
                ];
            };
            settings = mkOption {
              description = ''
                ini settings for wayfire.conf
                can be used for override of all other options
                however default options can not be removed
              '';
              type = iniFormat.type;
              default = defaults;
            };
            xdgOptions = mkOption {
              type = bool;
              description = "whether to set some XDG options such as CURRENT_DESKTOP";
              default = true;
            };
          };
        }
      );
    };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      WAYFIRE_CONFIG_FILE = "${configFilePath}";
      XDG_CURRENT_DESKTOP = "sway";
    };
    home.packages = with pkgs; [
      cfg.package
      wayfirePlugins.wcm
      wf-config
    ];
    xdg.configFile."wayfire.conf" = mkIf (cfg.settings != { }) {
      source = iniFormat.generate "wayfire.conf" (recursiveMerge [
        defaults
        { command = cfg.bindings; }
        { core.plugins = concatStringsSep " " cfg.extraPlugins; }
        cfg.settings
      ]);
    };
  };
}
