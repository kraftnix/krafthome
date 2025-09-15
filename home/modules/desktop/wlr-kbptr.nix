localFlake:
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
    mkOption
    types
    ;
  cfg = config.programs.wl-kbptr;

  keybindModule =
    { config, ... }:
    {
      options = {
        enable = mkOption {
          description = "enable keybind";
          default = false;
          type = types.bool;
        };
        exec = mkOption {
          description = "prefixes exec to the given command (hyprland requires a comma after exec but sway does not";
          default = false;
          type = types.bool;
        };
        mapping = mkOption {
          description = "keymap key (combined with $mod) to generate final keymap (like $mod+<key>)";
          default = "";
          type = types.str;
          example = "d";
        };
        command = mkOption {
          description = "keymap key (combined with $mod) to generate final keymap (like $mod+<key>)";
          default = "";
          type = types.str;
          example = "exec firefox";
        };
        modKey = mkOption {
          description = "mod key to use, defaults to $mod";
          default = "$mod";
          type = types.str;
        };
        extraKeys = mkOption {
          description = "mod key to use, defaults to $mod";
          default = [ ];
          type = types.listOf types.str;
          example = [ "Shift" ];
        };
      };
    };
  keybindsSubmodule =
    { config, ... }:
    {
      options = {
        sway = mkOption {
          description = "Keybindings to add to {khome.desktop.wm.sway.keybindings}, all keymaps are prefixed by the relevant wm $mod";
          default = { };
          type = types.submodule keybindModule;
        };
        hyprland = mkOption {
          description = "Keybindings to add to {programs.hyprland}, all keymaps are prefixed by the relevant wm $mod";
          default = { };
          type = types.submodule keybindModule;
        };
      };
    };

  toHyprlandMod =
    keymap:
    lib.concatStringsSep " " (
      lib.flatten [
        keymap.modKey
        keymap.extraKeys
      ]
    );
  toSwayMod =
    keymap:
    lib.concatStringsSep "+" (
      lib.flatten [
        keymap.modKey
        keymap.extraKeys
        keymap.mapping
      ]
    );
in
{
  ##### interface
  options.programs.wl-kbptr = {
    enable = mkOption {
      description = "Whether to enable wl-kbptr completion.";
      default = false;
      type = types.bool;
    };

    keybinds = mkOption {
      description = "Keybinds to configure for this wl-kbptr";
      default = { };
      type = types.attrsOf (
        lib.types.submoduleWith {
          modules = [
            keybindModule
            keybindsSubmodule
            (
              { config, ... }:
              {
                config.enable = mkDefault true;
                config.hyprland = mkIf config.enable {
                  enable = mkDefault true;
                  exec = mkDefault config.exec;
                  mapping = mkDefault config.mapping;
                  command = mkDefault config.command;
                  modKey = mkDefault config.modKey;
                  extraKeys = mkDefault config.extraKeys;
                };
                config.sway = mkIf config.enable {
                  enable = mkDefault true;
                  exec = mkDefault config.exec;
                  mapping = mkDefault config.mapping;
                  command = mkDefault config.command;
                  modKey = mkDefault config.modKey;
                  extraKeys = mkDefault config.extraKeys;
                };
              }
            )
          ];
        }
      );
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    home.packages = [ pkgs.wl-kbptr ];

    programs.wl-kbptr.keybinds = {
      mouse_mode = {
        mapping = "f";
        extraKeys = [ "Shift" ];
        sway.command = "mode Mouse";
        hyprland.command = "submap,resize";
      };
      float_click = {
        mapping = "a";
        command = "wl-kbptr -o modes=floating,click -o mode_floating.source=detect";
      };
      float = {
        mapping = "a";
        command = "wl-kbptr -o modes=floating -o mode_floating.source=detect";
        extraKeys = [ "Shift" ];
      };
    };

    programs.hyprland.binds = lib.pipe cfg.keybinds [
      (lib.filterAttrs (_: k: k.enable && k.hyprland.enable))
      (lib.mapAttrsToList (
        _: k: {
          "${toHyprlandMod k.hyprland}".${k.hyprland.mapping} =
            "${lib.optionalString k.hyprland.exec "exec, "}${k.hyprland.command}";
        }
      ))
      lib.mkMerge
    ];

    wayland.windowManager.sway.config = {
      keybindings = lib.pipe cfg.keybinds [
        (lib.filterAttrs (_: k: k.enable && k.sway.enable))
        (lib.mapAttrsToList (
          _: k: {
            "${toSwayMod k.sway}" = "${lib.optionalString k.sway.exec "exec "}${k.sway.command}";
          }
        ))
        lib.mkMerge
      ];
    };

    # NOTE: can't move this into modes since --release keybinds aren't supported there
    wayland.windowManager.sway.extraConfig = ''
      mode Mouse {
        bindsym a mode default, exec 'wl-kbptr-sway-active-win; swaymsg mode Mouse'
        bindsym Shift+a mode default, exec 'wl-kbptr; swaymsg mode Mouse'

        # Mouse move
        bindsym h seat seat0 cursor move -15 0
        bindsym j seat seat0 cursor move 0 15
        bindsym k seat seat0 cursor move 0 -15
        bindsym l seat seat0 cursor move 15 0

        # Left button
        bindsym s seat seat0 cursor press button1
        bindsym --release s seat seat0 cursor release button1

        # Middle button
        bindsym d seat seat0 cursor press button2
        bindsym --release d seat seat0 cursor release button2

        # Right button
        bindsym f seat seat0 cursor press button3
        bindsym --release f seat seat0 cursor release button3

        bindsym Escape mode default
      }
    '';

  };
}
