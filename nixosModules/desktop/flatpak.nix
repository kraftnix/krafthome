{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.desktop.flatpak;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.khome.desktop.flatpak.enable = mkEnableOption "enable flatpak integratioin";

  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
    };
  };
}
