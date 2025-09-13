{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.services.kanshi;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "services" "kanshi" "profiles" ]
      [ "services" "kanshi" "profiles" ]
    )
  ];

  options.khome.desktop.services.kanshi = {
    enable = opts.enable "enable kanshi, a dynamic display configuration service for wayland.";
  };

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
    };
  };
}
