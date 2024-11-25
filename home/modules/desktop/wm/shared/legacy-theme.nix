{self, ...}: {
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    ;
  cfg = config.khome.desktop.wm;
  opts = self.inputs.extra-lib.lib.options;
in {
  options.khome.desktop.wm = {
    legacyTheme = {
      enable = opts.enable "enable legacy theme";
      extraConfig = opts.string ''
        include colorscheme
        # Basic color configuration using the Base16 variables for windows and borders.
        # Property Name         Border  BG      Text    Indicator Child Border
        client.focused          $base05 $base0D $base00 $base0D $base0D
        client.focused_inactive $base01 $base01 $base05 $base03 $base01
        client.unfocused        $base01 $base00 $base05 $base01 $base01
        client.urgent           $base08 $base08 $base00 $base08 $base08
        client.placeholder      $base00 $base00 $base05 $base00 $base00
        client.background       $base07
      '' "extra config for legacy theme";
    };
  };

  config = mkIf cfg.legacyTheme.enable {
    khome.desktop.wm.sharedExtraConfig = cfg.legacyTheme.extraConfig;
  };
}
