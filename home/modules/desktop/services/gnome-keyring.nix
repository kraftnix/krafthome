{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional optionals;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.services.gnome-keyring;
in {
  options.khome.desktop.services.gnome-keyring = {
    enable = opts.enable "enable gnome-keyring";
  };

  config = mkIf cfg.enable {
    services.gnome-keyring.enable = true;
    services.gnome-keyring.components = ["secrets"];
  };
}
