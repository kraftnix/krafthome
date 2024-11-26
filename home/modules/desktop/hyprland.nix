args:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  inherit (lib.types)
    attrsOf
    enum
    oneOf
    package
    str
    ;
  cfg = config.programs.hyprland;
  # Pretty print
  hyprlandFomatted =
    str:
    pkgs.stdenv.mkDerivation {
      name = "hyprland.lua";
      preformatted = pkgs.writeText "pre-formatted-hyprland.lua" str;
      phases = [ "buildPhase" ];
      buildPhase = "${pkgs.luaformatter}/bin/lua-format $preformatted > $out";
      allowSubstitutes = false; # will never be in cache
    };
  variablesStr = concatStringsSep "\n" (
    mapAttrsToList (var: value: "\$${var} = ${value}") cfg.variables
  );
  mapVal = concatStringsSep ", ";

  # bindsStr = concatStringsSep "\n" (mapAttrsToList (desc: maps: ''
  #   # ${desc}
  #   bind = ${mapVal maps}
  # '') cfg.binds);
  bindsStr = concatStringsSep "\n" (
    flatten (
      mapAttrsToList (baseBind: maps: ''
        # ## Bindings for `${baseBind}`
        ${concatStringsSep "\n" (mapAttrsToList (key: cmd: "bind = ${baseBind}, ${key}, ${cmd}") maps)}
      '') cfg.binds
    )
  );

  execOnceStr = concatStringsSep "\n" (
    mapAttrsToList (desc: cmd: ''
      # ${desc}
      exec-once = ${cmd}
    '') cfg.execOnce
  );

  execStr = concatStringsSep "\n" (
    mapAttrsToList (desc: cmd: ''
      # ${desc}
      exec = ${cmd}
    '') cfg.exec
  );

  mapWindowRules =
    name: rules:
    concatStringsSep "\n" (
      mapAttrsToList (match: actions: ''
        # `${match}` ${name}'s
        ${concatStringsSep "\n" (map (action: "${name} = ${action}, ${match}") actions)}
      '') rules
    );
  windowRulesStr = mapWindowRules "windowrule" cfg.windowRules;
  windowRulesV2Str = mapWindowRules "windowrulev2" cfg.windowRulesV2;

  mapGroup = group: groupCfg: ''
    ${group} {
      ${
        concatStringsSep "\n" (
          mapAttrsToList (
            field: vals:
            if builtins.typeOf vals == "set" then
              ''
                ${field} {
                          ${
                            concatStringsSep "\n" (
                              mapAttrsToList (
                                n: c: if builtins.typeOf c == "set" then mapGroup n c else "${n} = ${toString c}"
                              ) vals
                            )
                          }
                        }''
            else
              "${field} = ${mapVal vals}"
          ) groupCfg
        )
      }
    }
  '';

  groupType =
    with types;
    attrsOf (
      nullOr (oneOf [
        str
        (listOf str)
        int
        float
        attrs
        bool
      ])
    );
  groupApply =
    vals:
    mapAttrs (
      _: c:
      if builtins.typeOf c == "list" then
        c
      else if builtins.typeOf c == "set" then
        groupApply c
      else
        [ (toString c) ]
    ) (filterAttrs (_: c: c != null) vals);
  groupOption =
    name:
    mkOption {
      type = groupType;
      apply = groupApply;
      default = { };
      description = "${name} Group Option";
    };
in
{
  options.programs.hyprland = {
    enable = mkEnableOption "hyprland";
    # Is this needed?
    layout = mkOption {
      type = types.enum [
        "dwindle"
        "master"
        "hy3"
      ];
      default = "hy3";
      description = ''
        Layout mode, auto-installs hy3 if wanted.
          - hy3(plugin): i3-like window management, requires new bindings (added here)
            see:
              - config: https://git.outfoxxed.me/outfoxxed/nixnew/src/branch/master/modules/hyprland/hyprland.conf
              - repo: https://github.com/outfoxxed/hy3
          - dwindle(integrated): Dwindle is a BSPWM-like layout, where every window on
                                 a workspace is a member of a binary tree.
          - master(integrated): The master layout makes one (or more) window(s) be the “master”,
                                taking (by default) the left part of the screen, and tiles the
                                rest on the right. You can change the orientation on per-workspace
                                basis if you want to use anything other than the default left/right split.
      '';
    };
    isMain = mkEnableOption "hyprland is main wm";
    package = mkOption {
      type = package;
      default = pkgs.hyprland;
      defaultText = literalExpression "pkgs.hyprland";
      description = "The package to use for the hyprland binary.";
    };
    plugins = mkOption {
      type = attrsOf (oneOf [
        package
        str
      ]);
      default = {
        inherit (pkgs.hyprlandPlugins) hy3;
      };
      apply = mapAttrs (n: p: if (builtins.typeOf p) == "string" then p else "${p}/lib/lib${n}.so");
      # "plugin = ${cfg.extraPackages.hy3}/lib/libhy3.so"
      defaultText = literalExpression "{ hy3 = pkgs.hy3-master; }";
      description = ''
        Extra packages / plugins used by this module. type handling:
          - package: tries to inher location of `.so` file of plugin, may fail.
          - str: path to the `.so` plugin file
      '';
    };
    variables = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          str
          int
          float
        ]);
      apply = mapAttrs (_: toString);
      default = {
        opacity = 0.97;
      };
      description = "code to be added before `return {}` in hyprland lua config";
    };

    binds = mkOption {
      type = attrsOf (attrsOf str);
      default = { };
      description = "hyprland binds";
    };
    exec = mkOption {
      type = types.attrsOf types.str;
      default = { };
      apply = filterAttrs (_: s: s != "");
      description = "exec's";
    };
    execOnce = mkOption {
      type = types.attrsOf types.str;
      default = { };
      apply = filterAttrs (_: s: s != "");
      description = "execOnce's";
    };
    windowRules = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      apply = filterAttrs (_: s: s != [ ]);
      description = "`windowrule` list";
    };
    windowRulesV2 = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = { };
      apply = filterAttrs (_: s: s != [ ]);
      description = "`windowrulev2` list";
    };

    gestures = groupOption "Gestures";
    decoration = groupOption "Decoration";
    animations = mkOption {
      default = "";
      description = "animations";
    };
    general = groupOption "General";
    input = groupOption "Input";
    dwindle = groupOption "Dwindle";
    master = groupOption "Master";
    plugin = groupOption "Plugin Configuration Options";

    extraPre = mkOption {
      default = "";
      description = "extra conf to add before final config string";
    };
    extraPost = mkOption {
      default = "";
      description = "extra conf to add after final config string";
    };

    config = mkOption {
      type = types.path;
      default = pkgs.writeText "hyprland.conf" cfg.configStr;
      description = "main hyprland.conf";
    };
    configStr = mkOption {
      type = types.str;
      description = "final config string";
      default = ''
        # ### Plugin
        ${optionalString (cfg.layout == "hy3") ''
          plugin = ${cfg.plugins.hy3}
        ''}

        # ### Variables
        ${variablesStr}

        # ### Extra Pre
        ${cfg.extraPre}

        # ### Execs
        ${execOnceStr}
        ${execStr}

        # ### Group Mappings
        ${mapGroup "general" cfg.general}
        ${mapGroup "input" cfg.input}
        ${mapGroup "gestures" cfg.gestures}
        ${mapGroup "decoration" cfg.decoration}
        ${mapGroup "dwindle" cfg.dwindle}
        ${mapGroup "master" cfg.master}
        ${mapGroup "plugin" cfg.plugin}

        # ### Animations
        animations {
          ${cfg.animations}
        }


        # ### Binds
        ${bindsStr}

        # ### Window Rules
        ${windowRulesStr}

        # ### Window Rules
        ${windowRulesV2Str}

        # ### Extra Post
        ${cfg.extraPost}
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."hypr/hyprland.conf".source = cfg.config;
    programs.hyprland.general.layout = cfg.layout;
  };
}
