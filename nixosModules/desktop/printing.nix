{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.khome.desktop.printing;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.khome.desktop.printing = {
    enable = mkEnableOption "enable printing (cups)";
    canon = mkEnableOption "enable canon driver";
    enableUnfreeConfig = mkEnableOption "enable configuring nixpkgs unfree predicate for canono";
  };

  config = mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.drivers = with pkgs;
      mkIf cfg.canon [
        canon-cups-ufr2
        cnijfilter2
      ];
    # NOTE: doesn't include canon G650 printer drivers :(
    nixpkgs = mkIf (cfg.enableUnfreeConfig && cfg.canon) {
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "canon-cups-ufr2"
          "cnijfilter2"
        ];
    };
  };
}
