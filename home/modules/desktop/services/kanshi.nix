{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    optional
    optionals
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.services.kanshi;
in
{
  options.khome.desktop.services.kanshi = {
    enable = opts.enable "enable kanshi";
  };

  config = mkIf cfg.enable {
    services.kanshi = {
      enable = true;
    };
  };
}
