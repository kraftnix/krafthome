args:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;
  cfg = config.khome.desktop.swaynotificationcenter;
in
{
  options.khome.desktop.swaynotificationcenter = {
    enable = mkEnableOption "anyrun khome swaynotificationcenter config";
    extraConfig = mkOption {
      default = { };
      description = "extra config to add to the swaync config json at `/etc/swaync/config.json`";
      type = types.attrsOf types.raw;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ swaynotificationcenter ];
    xdg.configFile."swaync/config.json".text = builtins.toJSON (
      lib.mkMerge [
        (lib.mapAttrs (_: lib.mkDefault) {
          "$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
          timeout-critical = 20;
          timeout = 10;
          timeout-low = 5;
          script-fail-notify = true;
          widgets = [ "mpris" ];
          widget-config.mpris = {
            image-size = 64;
            image-radius = 20;
          };
        })
      ]
    );

    khome.desktop.wm.shared.binds.swaynotificationcenter = {
      enable = true;
      exec = true;
      mapping = lib.mkDefault "n";
      extraKeys = lib.mkDefault [ "Ctrl" ];
      command = "swaync-client -t";
    };
  };
}
