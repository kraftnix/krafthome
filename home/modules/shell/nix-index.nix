args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.shell.nix-index;
in {
  options.khome.shell.nix-index = {
    enable = mkEnableOption "enable nix-index";
    enableComma = mkEnableOption "use comma instead of nix-index";
  };

  config = mkIf cfg.enable {
    # programs.command-not-found.enable = true;
    programs.nix-index.enable = true;
    # programs.nix-index.enable = lib.mkForce (! cfg.enableComma);
    # programs.nix-index-database.comma.enable = true;
  };
}
