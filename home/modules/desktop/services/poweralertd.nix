{ self, ... }:
{
  config,
  lib,
  ...
}:
{
  options.khome.desktop.services.poweralertd = {
    enable = lib.mkEnableOption "enable battery low alerts";
  };

  config = lib.mkIf config.khome.desktop.services.poweralertd.enable {
    services.poweralertd.enable = true;
  };
}
