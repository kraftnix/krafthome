{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  inherit (lib)
    mkIf
    mkDefault
    mkMerge
    mkOption
    types
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.terminals.wezterm;
in
{
  options.khome.desktop.terminals.wezterm = {
    # until this is resolved: https://github.com/wez/wezterm/issues/5990
    package = opts.package self.packages.${pkgs.system}.wezterm-upstream "wezterm package to use";
    front_end = mkOption {
      type = types.enum [
        "OpenGL"
        "Software"
        "WebGpu"
      ];
      default = "OpenGL";
      description = "frontend used for hardware acceleration";
    };
    style = opts.enable' (cfg.simple || cfg.full) "enable style settings";
    simple = opts.enable "enable simple settings";
    full = opts.enable "enable full settings";
    hyperlink-rules = opts.enable' cfg.full "enable hyperlink-rules settings";
    resize-mode = opts.enable' cfg.full "enable resize-mode settings";
    copy-mode = opts.enable' cfg.full "enable copy-mode settings";
  };

  config = mkMerge [
    {
      programs.wezterm.package = mkDefault cfg.package;
      khome.programs.wezterm.package = mkDefault cfg.package;
    }
    (mkIf cfg.simple (import ./simple.nix args))
    (mkIf cfg.style (import ./style.nix args))
    (mkIf cfg.full (import ./full.nix args))
    (mkIf cfg.copy-mode (import ./copy-mode.nix args))
    (mkIf cfg.resize-mode (import ./resize-mode.nix))
    # ++ (optional cfg.hyperlink-rules ./hyperlink-rules.nix)
  ];
}
