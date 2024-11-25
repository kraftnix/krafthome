args: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.nushell-unstable;
  format = pkgs.formats.json {};
  defaultEnv = {
    PROMPT_COMMAND = "{ create_left_prompt_original }";
    PROMPT_COMMAND_RIGHT = "{ create_right_prompt }";
    PROMPT_INDICATOR = ''"〉"'';
    PROMPT_INDICATOR_VI_INSERT = ''": "'';
    PROMPT_INDICATOR_VI_NORMAL = ''"〉"'';
    PROMPT_MULTILINE_INDICATOR = ''"::: "'';
    # ENV_CONVERSIONS = ''{
    #   "PATH": {
    #     from_string: { |s| $s | split row (char esep) }
    #     to_string: { |v| $v | str collect (char esep) }
    #   }
    #   "Path": {
    #     from_string: { |s| $s | split row (char esep) }
    #     to_string: { |v| $v | str collect (char esep) }
    #   }
    # }'';
    NU_LIB_DIRS = ''      [
              ($nu.config-path | path dirname | path join 'scripts')
          ]'';
    NU_PLUGIN_DIRS = ''      [
              ($nu.config-path | path dirname | path join 'plugins')
          ]'';
  };
  starshipEnv = {
    PROMPT_INDICATOR = ''""'';
    PROMPT_COMMAND = ''{ || starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)' }'';
    PROMPT_COMMAND_RIGHT = ''      { ||
            let time_segment = ([
                (date now | date format '%m/%d/%Y %r')
            ] | str join)
            $time_segment
          }'';
    STARSHIP_SHELL = ''"nu"'';
  };
  env =
    defaultEnv
    // (optionalAttrs cfg.enableStarship starshipEnv)
    // cfg.extraEnv;
  defaultKeybindings = {
    completion_menu = {
      modifier = "none";
      keycode = "tab";
      mode = "emacs"; # Options: emacs vi_normal vi_insert
      event = {
        until = [
          {
            send = "menu";
            name = "completion_menu";
          }
          {send = "menunext";}
        ];
      };
    };
    completion_previous = {
      modifier = "shift";
      keycode = "backtab";
      mode = ["emacs" "vi_normal" "vi_insert"]; # Note: You can add the same keybinding to all modes by using a list";
      event = {send = "menuprevious";};
    };
    history_previous = {
      modifier = "control";
      keycode = "char_p";
      mode = "emacs";
      event = {
        until = [
          {send = "menupageprevious";}
          {edit = "undo";}
        ];
      };
    };
    history_menu = {
      modifier = "control";
      keycode = "char_r";
      mode = "emacs";
      event = {
        until = [
          {
            send = "menu";
            name = "history_menu";
          }
          {send = "menupagenext";}
        ];
      };
    };
  };
in {
  options.programs.nushell-unstable = {
    enable = mkEnableOption "nushell-unstable (0.60+)";
    enableStarship = mkEnableOption "starship integration";

    package = mkOption {
      type = types.package;
      default = pkgs.nushell;
      defaultText = literalExample "pkgs.nushell-unstable";
      description = "The package to use for nushell.";
    };

    scripts = mkOption {
      type = types.listOf types.path;
      default = [];
      description = "List of scripts to source and link into ~/.config/nushell/scripts";
    };

    plugins = mkOption {
      type = types.listOf types.path;
      default = [];
      description = "List of plugins to source and link into ~/.config/nushell/plugins";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = literalExpression ''
        {
          TESTING_STRING = ''$"STRING_VALUE"''$;
          TESTING_RUN_COMMANd = "(pwd)";
        };
      '';
      description = "Environment Variables to add";
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      defaultText = literalExample ''
        $env.CUSTOM_ENV = AVALUE
      '';
      description = "Extra code to add to config.nu";
    };

    theme = mkOption {
      type = with types;
        submodule {
          freeformType = format.type;
          options = {};
        };
      default = {};
      description = "Theme options.";
    };
    settings = mkOption {
      type = with types;
        submodule {
          freeformType = format.type;
          options = {
            keybindings = mkOption {
              type = types.attrsOf attrs;
              default = {};
              apply = val:
                mapAttrsToList
                (
                  name: cfg:
                    cfg // {inherit name;}
                )
                (filterAttrs (_: v: v != {}) (recursiveUpdate defaultKeybindings val));
              description = ''
                Keybindings for nushell, has overridable defaults, set to empty attrSet ({}) to remove keybinding completely.
              '';
            };
          };
        };
      default = {};
      example = literalExample ''
        {
          edit_mode = "vi";
          startup = [ "alias la [] { ls -a }" "alias e [msg] { echo $msg }" ];
          key_timeout = 10;
          completion_mode = "circular";
          no_auto_pivot = true;
        }
      '';
      description = ''
        Configuration written to
        <filename>~/.config/nushell/config.toml</filename>.
        </para><para>
        See <link xlink:href="https://www.nushell.sh/book/configuration.html" /> for the full list
        of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    xdg.configFile = mkMerge [
      {
        "nushell/config.nu".text =
          builtins.readFile ./baseConfig.nu
          + ''
            ${ # source provided scripts
              concatStringsSep "\n" (map (
                  path: "source ${path}"
                )
                cfg.scripts)
            }

            $env.config = ${builtins.readFile (format.generate "config" cfg.settings)}
            ${ # update theme if provided
              optionalString (cfg.theme != {})
              "let $config = ($config | upsert theme ${builtins.toJSON cfg.theme})"
            }

            ${cfg.extraConfig}
          '';
        "nushell/env.nu".text = ''
          ${builtins.readFile ./baseEnv.nu}
          ${ # setup environment / env variables
            concatStringsSep "\n" (mapAttrsToList (
                env: val: "$env.${env} = ${val}"
              )
              env)
          }
        '';
      }
      # Symlink scripts + plugins into nushell default locations
      (listToAttrs (map
        (
          path:
            nameValuePair "nushell/scripts/${builtins.baseNameOf path}" {source = path;}
        )
        cfg.scripts))
      (listToAttrs (map
        (
          path:
            nameValuePair "nushell/plugins/${builtins.baseNameOf path}" {source = path;}
        )
        cfg.plugins))
    ];
  };
}
