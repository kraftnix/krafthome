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
  cfg = config.khome.desktop.wm.shared;

  toNiriMod =
    keymap:
    lib.concatStringsSep "+" (
      lib.flatten [
        (lib.optional keymap.mod keymap.modKey)
        keymap.extraKeys
        keymap.mapping
      ]
    );
  toHyprlandMod =
    keymap:
    lib.concatStringsSep " " (
      lib.flatten [
        (lib.optional keymap.mod keymap.modKey)
        keymap.extraKeys
      ]
    );
  toSwayMod =
    keymap:
    lib.concatStringsSep "+" (
      lib.flatten [
        (lib.optional keymap.mod keymap.modKey)
        keymap.extraKeys
        keymap.mapping
      ]
    );
in
{
  imports = [
    ./default-keybinds.nix
  ];

  options.khome.desktop.wm.shared = {
    enableBinds = mkOption {
      description = "Enables mapping binds to relevant window managers";
      default = false;
      type = types.bool;
    };

    binds = mkOption {
      description = "Keybinds to configure for this wl-kbptr";
      default = { };
      type = types.attrsOf (
        types.submoduleWith {
          specialArgs = {
            # TODO: make configurable
            hyprlandMod = "$mod";
            swayMod = "$mod";
            niriMod = "Mod";
          };
          modules = [ ./bind.nix ];
        }
      );
    };
  };

  ##### implementation
  config = mkIf cfg.enableBinds {

    programs.niri.settings.binds = lib.pipe cfg.binds [
      (lib.filterAttrs (_: k: k.enable && k.niri.enable))
      (lib.mapAttrsToList (
        _: k: {
          ${toNiriMod k.niri} = k.niri.output;
        }
      ))
      lib.mkMerge
    ];

    programs.hyprland.binds = lib.pipe cfg.binds [
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
      keybindings = lib.pipe cfg.binds [
        (lib.filterAttrs (_: k: k.enable && k.sway.enable))
        (lib.mapAttrsToList (
          _: k: {
            "${toSwayMod k.sway}" = "${lib.optionalString k.sway.exec "exec "}${k.sway.command}";
          }
        ))
        lib.mkMerge
      ];
    };

  };
}
