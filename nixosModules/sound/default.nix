{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.sound;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  imports = [
    ./bluetooth.nix
    ./pipewire.nix
  ];

  options.khome.sound = {
    enable = mkEnableOption "enable basic sound";
    pulse.enable = mkEnableOption "enable pulse audio";
    corePackages = mkOption {
      default = with pkgs; [
        helvum # GTK pipewire patch bay
        # cadence # GTK jack audio tools # deprecated
        pavucontrol # volume control
        easyeffects # audio post processing
        waypipe # network proxy for wayland clients
      ];
      description = "core packages for sound";
      type = types.listOf types.package;
    };
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = cfg.pulse.enable;
    environment.systemPackages = with pkgs; cfg.corePackages;
  };
}
