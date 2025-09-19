{ inputs, ... }:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.anyrun;
in
{
  options.khome.desktop.anyrun = {
    enable = mkEnableOption "anyrun khome anyrun config";
    keybind = mkOption {
      default = "";
      description = "keybind to add to hyprland/sway with Mod+{keybind}, empty string to disasble";
      type = types.str;
    };
    plugins = mkOption {
      default = [
        "applications"
        "dictionary"
        "kidex"
        "randr"
        "rink"
        "shell"
        "stdin"
        "symbols"
        # translate # only google translate
        "websearch"
        # inputs.cryptorun.packages.${pkgs.system}.default
      ];
      description = "plugins to use";
      type = with types; nullOr (listOf (either package str));
    };
    cssFile = mkOption {
      default = ./anyrun.css;
      description = "anyrun style css";
      type = types.path;
    };
    extraConfig = mkOption {
      default = { };
      description = "extra config to add to `programs.anyrun.config`";
      type = types.raw;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."anyrun/style.css".source = cfg.cssFile;

    programs.anyrun = {
      enable = true;
      config = mkMerge [
        {
          inherit (cfg) plugins;
          # width.fraction = 0.3;
          # verticalOffset.absolute = 15;
          hidePluginInfo = true;
          closeOnClick = true;
        }
        cfg.extraConfig
      ];
    };

    khome.desktop.wm.shared.binds.anyrun = {
      enable = cfg.keybind != "";
      exec = true;
      mapping = cfg.keybind;
      command = "anyrun";
    };

  };
}
