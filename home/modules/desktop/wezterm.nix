{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkForce
    mkIf
    mkOption
    literalExpression
    types
    ;
  cfg = config.khome.programs.wezterm;
  # Pretty print
  weztermFomatted = str:
    pkgs.stdenv.mkDerivation {
      name = "wezterm.lua";
      preformatted = pkgs.writeText "pre-formatted-wezterm.lua" str;
      phases = ["buildPhase"];
      buildPhase = "${pkgs.luaformatter}/bin/lua-format $preformatted > $out";
      allowSubstitutes = false; # will never be in cache
    };
in {
  # disabledModules = [ "programs/wezterm.nix" ];
  options.khome.programs.wezterm = {
    enable = mkEnableOption "wezterm (0.60+)";
    package = mkOption {
      type = types.package;
      default = pkgs.wezterm;
      defaultText = literalExpression "pkgs.wezterm";
      description = "The package to use for the wezterm binary.";
    };
    defaultPre = mkOption {
      type = types.str;
      default = ''
        local wezterm = require 'wezterm';
        local act = wezterm.action
      '';
      description = "code to be added before `return {}` in wezterm lua config";
    };
    config = mkOption {
      type = types.path;
      default = weztermFomatted cfg.configStr;
      description = "Wezterm defined config";
    };
    configStr = mkOption {
      type = types.str;
      description = "Final config string";
      default = ''
        ${cfg.defaultPre}
        ${cfg.extraPre}
        return {
          ${inputs.provision.lib.misc.toLua cfg.settings}
        }
      '';
    };
    extraPre = mkOption {
      type = types.separatedString "\n";
      default = "";
      description = "Config added after default and before final return in config string";
    };
    settings = mkOption {
      type = with types;
        submodule {
          freeformType = attrsOf (oneOf [attrs str int float bool (listOf (oneOf [attrs str int float bool]))]);
          options = {};
        };
      default = {};
      example = literalExpression ''
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
        <filename>~/.config/wezterm/wezterm.lua</filename>.
        </para><para>
        See <link xlink:href="https://wezfurlong.org/wezterm/config/files.html" /> for the full list
        of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package cfg.package.terminfo];

    programs.wezterm.enable = true;
    # breaks neovim terminals in tmux: https://github.com/wez/wezterm/issues/5007
    programs.wezterm.enableBashIntegration = false;
    programs.wezterm.enableZshIntegration = false;

    xdg.configFile."wezterm/wezterm.lua" = mkForce {
      source = cfg.config;
    };
    #xdg.configFile."wezterm/wezterm.lua".text = ''
    #  local wezterm = require 'wezterm';
    #  ${cfg.extraPre}
    #  return {
    #    ${lib.khome.misc.toLua cfg.settings}
    #  }
    #'';
  };
}
