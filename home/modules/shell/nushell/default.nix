{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    any
    concatStringsSep
    elem
    filterAttrs
    flatten
    flip
    getExe
    hasSuffix
    literalExpression
    mapAttrs
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkOverride
    optionalString
    types
    typeOf
    ;
  inherit (inputs.home.lib) hm;
  cfg = config.khome.nushell;
  # # which plugins to use on start
  # let autostartPlugins = [ ${
  #   concatStringsSep " " (
  #     filter (plugin: elem plugin cfg.autoStartPlugins) cfg.plugins
  #   )
  # } ]
  # let plugins = (plugin list)
  # $autostartPlugins | each { |plugin|
  #   if ($plugins | where name == $plugin | length) > 0 {
  #     plugin use $plugin
  #   }
  # }
  configNuText = ''
    # load plugins
    ${concatStringsSep "\n" (
      map (plugin: ''
        plugin add ${getExe plugin}
        ${optionalString (elem plugin cfg.autoStartPlugins) "plugin use ${plugin}"}
      '') cfg.plugins
    )}

    # source provided scripts
    ${concatStringsSep "\n" (map (path: "source ${path}") cfg.scripts)}
    # source provided scriptDirs
    ${concatStringsSep "\n" (map (path: "source ${path}") cfg.scriptDirs)}

    ${builtins.readFile ./src/config.nu}

    def smn [] {
      ^manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf | xargs manix
    }

    ${cfg.extraConfig}
  '';

  # mainly to prevent clashes between non-nu aliases imported and nu functions
  removeShellAliases = flip removeAttrs cfg.removeShellAliases;

  # import home shell aliases
  otherShellAliases = mapAttrs (_: mkOverride 900) config.home.shellAliases;

  getScriptsFromDir =
    dir:
    mapAttrsToList (name: c: "${dir}/${name}") (
      filterAttrs (name: _: hasSuffix ".nu" name) (builtins.readDir "${dir}")
    );
in
# scriptDir = builtins.readDir "${inputs.nu-scripts}";
# nuScripts = mapAttrsToList
#   (name: c:
#     "${inputs.nu-scripts}/${name}"
#   )
#   (filterAttrs (name: _: hasSuffix ".nu" name) scriptDir);
{
  options.khome.nushell = {
    enable = mkEnableOption "nushell-unstable (0.60+)";

    enableStarship = mkEnableOption "starship integration" // {
      default = config.programs.starship.enable;
    };
    enableAtuin = mkEnableOption "atuin integration" // {
      default = config.programs.atuin.enable;
    };
    enablePayrespects = mkEnableOption "pay-respects integration" // {
      default = config.programs.pay-respects.enable;
    };

    removeShellAliases = mkOption {
      description = "mainly to prevent clashes between non-nu aliases imported and nu functions";
      default = [
        "ls"
        "du"
      ];
      type = types.listOf types.str;
    };

    package = mkOption {
      description = "The package to use for nushell.";
      default = pkgs.nushell;
      defaultText = literalExpression "pkgs.nushell-unstable";
      type = types.package;
    };

    scriptDirs = mkOption {
      description = "path to a directory containing nu scripts to import all from";
      default = [ ];
      type = types.listOf types.path;
      apply = dirs: flatten (map getScriptsFromDir dirs);
    };

    scripts = mkOption {
      description = "List of scripts to source and link into ~/.config/nushell/scripts";
      default = [ ];
      type = types.listOf types.path;
    };

    env = mkOption {
      description = ''
        Environment Variables to load into nushell with `load-env`.

        These are populated with entries from `home.sessionVariables`,
        but are overridable.

        Same type as home-manager upstream {programs.nushell.environmentVariables}
        Inline values can be set with `lib.hm.nushell.mkNushellInline`.
      '';
      default = { };
      example = lib.literalExpression ''
        {
          FOO = "BAR";
          LIST_VALUE = [ "foo" "bar" ];
          PROMPT_COMMAND = lib.hm.nushell.mkNushellInline '''{|| "> "}''';
          ENV_CONVERSIONS.PATH = {
            from_string = lib.hm.nushell.mkNushellInline "{|s| $s | split row (char esep) }";
            to_string = lib.hm.nushell.mkNushellInline "{|v| $v | str join (char esep) }";
          };
        }
      '';
      type = types.attrsOf hm.types.nushellValue;
    };

    autoStartPlugins = mkOption {
      description = "plugins to `use` when nushell is started";
      default = [ "explore" ];
      type = with types; listOf str;
    };

    plugins = mkOption {
      description = "List of plugins to source and link into ~/.config/nushell/plugins";
      default = with pkgs.nushellPlugins; [
        polars
        # net
        query
        gstat
        formats
        # explore
        # dbus
        # prometheus
        # dialog
        # skim
      ];
      type =
        with types;
        listOf (oneOf [
          path
          package
        ]);
    };

    extraConfig = mkOption {
      description = "Extra configuration to add to config.nu";
      default = "";
      type = types.lines;
    };

    shellAliases = mkOption {
      description = "Overrides for `home.shellAliases` + extra aliases";
      default = { };
      type = with types; attrsOf str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.carapace
      pkgs.starship
      pkgs.atuin
    ];
    home.sessionVariables = {
      NUSHELL_ENABLE_ATUIN = toString cfg.enableAtuin;
      NUSHELL_ENABLE_STARSHIP = toString cfg.enableStarship;
      NUSHELL_ENABLE_PAYRESPECTS = toString cfg.enablePayrespects;
      NUSHELL_ENABLE_ALIASES = toString true;
    };
    khome.nushell.env =
      mapAttrs (_: v: if (typeOf v) == "int" then toString v else "${v}") config.home.sessionVariables
      # home-manager upstream generates a non-functional ENV var for use with nushell here
      // (lib.optionalAttrs (config.xdg.systemDirs.config != [ ]) {
        XDG_CONFIG_DIRS = hm.nushell.mkNushellInline "[ ${lib.concatStringsSep ":" config.xdg.systemDirs.config} $env.XDG_CONFIG_DIRS ] | str join ':'";
      })
      // (lib.optionalAttrs config.programs.tmux.secureSocket {
        TMUX_TMPDIR = hm.nushell.mkNushellInline "$env.XDG_RUNTIME_DIR | default '/run/user/(id -u)'";
      });
    khome.nushell.shellAliases = mapAttrs (_: mkDefault) (
      removeShellAliases (
        config.home.shellAliases
        // {
          fport = "ss -tlpn";
          git-parent = "echo 'noop, use zsh instead'";
          gpu = "git pull upstream (git branch --show-current)";
          gppu = "git push -u origin (git branch --show-current)";
          otp = "echo 'noop, use zsh instead'";
          # ske = ''nu -c '$env.SSH_AUTH_SOCK = ($"/home/($env.USER)/.ssh/auth_sock" | path expand)' '';
          # skk = ''nu -c '$env.SSH_AUTH_SOCK = (ls /tmp/ | where name =~ "ssh-" | sort-by modified -r | get name | get 0) | get name.0' '';
          # skr = "nu -c '$env.SSH_AUTH_SOCK=$\"/run/user/(id -u $env.USER)/gnupg/S.gpg-agent.ssh\"'";
          ssh-fpscan = "sh -c 'ssh-keyscan localhost | ssh-keygen -lf -'";
          zen = "zenith --db $'($env.XDG_DATA_HOME)/zenith.db'";

          # home-manager
          hms = "home-manager switch --flake $'.#($env.USER)@($env.HOST)' switch";
          hmsb = "home-manager switch --flake $'.#($env.USER)@($env.HOST)' switch -b bak";
        }
        // (lib.optionalAttrs (any (p: p.pname == "nushell_plugin_explore") cfg.plugins) {
          explore = "nu_plugin_explore";
        })
      )
    );
    # I handle the integration myself
    programs.atuin.enableNushellIntegration = false;
    programs.starship.enableNushellIntegration = false;
    programs.pay-respects.enableNushellIntegration = false;
    programs.nushell = {
      enable = true;
      configFile.text = configNuText;
      # configFile.text = ''
      #   let enableAtuin = ${if cfg.enableAtuin then "true" else "false"}
      #   let enableStarship = ${if cfg.enableStarship then "true" else "false"}
      #   ${configNuText}
      # '';
      envFile.source = ./src/env.nu;
      environmentVariables = cfg.env;
      shellAliases = lib.mkForce cfg.shellAliases;
    };
    xdg.configFile = mkMerge [
      # Symlink scripts + plugins into nushell default locations
      # (listToAttrs (map
      #   (path:
      #     nameValuePair "nushell/scripts/${builtins.baseNameOf path}" { source = path; }
      #   ) cfg.scripts))
      # (listToAttrs (map
      #   (path:
      #     nameValuePair "nushell/plugins/${builtins.baseNameOf path}" { source = path; }
      #   ) cfg.plugins))
      {
        "nushell/atuin.nu".source = ./src/atuin.nu;
        "nushell/carapace.nu".source = ./src/carapace.nu;
        "nushell/pay-respects.nu".source = ./src/pay-respects.nu;
        "nushell/keybindings.nu".source = ./src/keybindings.nu;
        "nushell/menus.nu".source = ./src/menus.nu;
        "nushell/starship.nu".source = ./src/starship.nu;
        "nushell/theme.nu".source = ./src/theme.nu;
      }
    ];
  };
}
