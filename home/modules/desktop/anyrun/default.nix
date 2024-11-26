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
    mkOverride
    optionalString
    types
    ;
  anyrunPkgs = inputs.anyrun.packages.${pkgs.system};
  cfg = config.khome.desktop.anyrun;
in
{
  options.khome.desktop.anyrun = {
    enable = mkEnableOption "anyrun khome anyrun config";
    modKeybind = mkOption {
      default = "";
      description = "keybind to add to hyprland/sway with Mod+{keybind}, empty string to disasble";
      type = types.str;
    };
    modIncludeShift = mkEnableOption "add shift to generated keybind";
    plugins = mkOption {
      default = with anyrunPkgs; [
        applications
        dictionary
        kidex
        randr
        rink
        shell
        stdin
        symbols
        # translate # only google translate
        websearch
        # inputs.cryptorun.packages.${pkgs.system}.default
      ];
      description = "plugins to use";
      type = types.listOf types.package;
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

    programs.hyprland = mkIf (cfg.modKeybind != "") {
      binds."$mainMod${optionalString cfg.modIncludeShift " SHIFT"}"."${cfg.modKeybind}" = "exec, anyrun";
    };

    wayland.windowManager.sway.config = {
      keybindings = mkIf (cfg.modKeybind != "") {
        "$mod+${optionalString cfg.modIncludeShift "+"}${cfg.modKeybind}" = mkOverride 250 "exec anyrun";
      };
    };
  };
}
