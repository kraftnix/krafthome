args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.browsers.tor;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.khome.browsers.tor = {
    enable = mkEnableOption "enable tor browser";
    forceWayland = mkEnableOption "enable mozilla wayland flag";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf (cfg.forceWayland) {
      MOZ_ENABLE_WAYLAND = 1;
    };

    home.packages = with pkgs; [
      tor-browser
      tor
      arti
    ];
  };
}
