{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.media.steam;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.khome.media.steam = {
    enable = mkEnableOption "steam enablement";
    forceSteamUnfree = mkEnableOption "force allow steam command unfree predicate";
  };

  config = mkIf cfg.enable {
    # steam native
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    # not set by default due to potential conflict with how `nixpkgs` is set in NixOS
    nixpkgs = mkIf cfg.forceSteamUnfree {
      config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
          "steamcmd"
          "steam-run"
          "steam-runtime"
          "steam-original"
        ];
    };
  };
}
