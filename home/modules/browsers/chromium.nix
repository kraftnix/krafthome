args: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.browsers.chromium;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  options.khome.browsers.chromium = {
    enable = mkEnableOption "enable ungoogled chromium browser";
    forceWayland = mkEnableOption "force wayland chromium flags";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ungoogled-chromium];
    xdg.configFile = mkIf (cfg.forceWayland) {
      "chromium-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };
  };
}
