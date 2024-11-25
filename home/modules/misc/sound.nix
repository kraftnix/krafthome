args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.khome.misc.sound;
in {
  options.khome.misc.sound.enable = mkEnableOption "add sound packages";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      helvum # GTK pipewire patch bay
      # cadence # GTK jack audio tools # deprecated
      pavucontrol # volume control
      easyeffects # audio post processing
      waypipe # network proxy for wayland clients
    ];
  };
}
