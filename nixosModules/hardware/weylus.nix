{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.khome.hardware.weylus;
in
{
  options.khome.hardware.weylus.enable = mkEnableOption "enable weylus integration";

  config = mkIf cfg.enable {
    programs.weylus = {
      enable = true;
      openFirewall = true;
      #users = [ "<username>" ];
    };
  };
}
