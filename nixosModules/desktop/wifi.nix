{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.desktop.wifi;
  inherit (lib)
    mkEnableOption
    mkIf
    optional
    ;
in
{
  options.khome.desktop.wifi = {
    enable = mkEnableOption "enable wifi tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [ ] ++ (optional config.networking.wireless.iwd.enable impala) # TUI for iwd
    ;
  };
}
