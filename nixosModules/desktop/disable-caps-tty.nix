{
  config,
  lib,
  ...
}:
{
  options.khome.desktop.misc.disable_caps =
    lib.mkEnableOption "swap caps and escape at X server level";
  config = lib.mkIf config.khome.desktop.misc.disable_caps {
    services.xserver.xkb.options = "caps:swapescape";
    console.useXkbConfig = true;
  };
}
