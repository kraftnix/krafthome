{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.shell.tmux;
in {
  imports = [./core.nix];
  options.khome.shell.tmux = {
    enable = mkEnableOption "enable tmux";
    enableTheme =
      mkEnableOption "enable khome theme"
      // {
        default = config.khome.themes.enable;
      };
    hostcolor = opts.string config.khome.themes.hosts.currHostColour "if enabled, overrides the background colors for host";
  };
}
