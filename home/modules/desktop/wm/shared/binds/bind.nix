{
  config,
  lib,
  hyprlandMod,
  swayMod,
  niriMod,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;

  commonOptions.options = {
    enable = mkOption {
      description = "enable keybind";
      default = false;
      type = types.bool;
    };
    mod = mkOption {
      description = "prefixes the relevant Mod key to the given command";
      default = true;
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
    extraKeys = mkOption {
      description = "mod key to use, defaults to $mod";
      default = [ ];
      type = types.listOf types.str;
      example = [ "Shift" ];
    };
  };
  keybindModule.options = commonOptions.options // {
    modKey = mkOption {
      description = "mod key to use, defaults to $mod";
      default = "$mod";
      type = types.str;
    };
  };
  keybindsSubmodule =
    { config, ... }:
    {
      options = {
        niri = mkOption {
          description = "Keybindings to add to {programs.niri.settings.binds}, all keymaps are prefixed by the relevant wm Mod";
          default = { };
          type = types.submoduleWith {
            modules = [
              keybindModule
              (
                { config, ... }:
                {
                  options = {
                    output = mkOption {
                      description = "output object to add for keybind at {programs.niri.settings.binds.<bind>}";
                      default = { };
                      type = with types; attrsOf raw;
                    };
                  };
                  config = mkIf (config.exec && config.command != "") {
                    output.action.spawn-sh = config.command;
                  };
                }
              )
            ];
          };
        };
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

  hyprlandReplaceMap =
    lib.replaceStrings
      [
        "Shift"
        "Ctrl"
        "Alt"
        "Tab"
      ]
      [
        "SHIFT"
        "CTRL"
        "ALT"
        "TAB"
      ];
  swayNiriReplaceMap =
    lib.replaceStrings
      [
        "SHIFT"
        "CTRL"
        "ALT"
        "TAB"
      ]
      [
        "Shift"
        "Ctrl"
        "Alt"
        "Tab"
      ];
in
{
  imports = [
    commonOptions
    keybindsSubmodule
  ];

  config = {
    enable = mkDefault (config.command != "");
    hyprland = mkIf config.enable {
      enable = mkDefault true;
      exec = mkDefault config.exec;
      mod = mkDefault config.mod;
      mapping = mkDefault (hyprlandReplaceMap config.mapping);
      command = mkDefault config.command;
      modKey = mkDefault (if config.mod then hyprlandMod else "");
      extraKeys = mkDefault (lib.map hyprlandReplaceMap config.extraKeys);
    };
    sway = mkIf config.enable {
      enable = mkDefault true;
      exec = mkDefault config.exec;
      mod = mkDefault config.mod;
      mapping = mkDefault (swayNiriReplaceMap config.mapping);
      command = mkDefault config.command;
      modKey = mkDefault swayMod;
      extraKeys = mkDefault (lib.map swayNiriReplaceMap config.extraKeys);
    };
    niri = mkIf config.enable {
      enable = mkDefault true;
      exec = mkDefault config.exec;
      mod = mkDefault config.mod;
      mapping = mkDefault (swayNiriReplaceMap config.mapping);
      command = mkDefault config.command;
      modKey = mkDefault niriMod;
      extraKeys = mkDefault (lib.map swayNiriReplaceMap config.extraKeys);
    };
  };
}
