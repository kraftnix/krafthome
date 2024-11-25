{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.khome.media.bluray;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.khome.media.bluray = {
    enable = mkEnableOption "enable bluray tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [libaacs libbluray mpv cdrtools];
  };
}
