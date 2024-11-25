{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.sound.pipewire;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in {
  imports = [./media-session.nix];

  options.khome.sound.pipewire = {
    enable = mkEnableOption "use pipewire for sound" // {default = config.khome.sound.enable;};
    rtkit = mkEnableOption "enable real-time kit" // {default = true;};
    alsa.enable = mkEnableOption "enable alsa" // {default = true;};
    pulse.enable = mkEnableOption "enable pulse" // {default = config.khome.sound.pulse.enable;};
    jack.enable = mkEnableOption "enable jack";
    media-session.enable = mkEnableOption "enable media session";
    wireplumber.enable = mkEnableOption "enable wireplumber" // {default = true;};
  };

  config = mkIf cfg.enable {
    hardware.pulseaudio.enable = lib.mkForce false;
    security.rtkit.enable = cfg.rtkit;
    services.pipewire = {
      enable = true;

      alsa = mkIf cfg.alsa.enable {
        enable = true;
        support32Bit = true;
      };

      jack.enable = cfg.jack.enable;

      wireplumber = mkIf cfg.wireplumber.enable {
        enable = true;
        extraConfig = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            # attempt enforce A2DP while using mic on headphones
            "bluez5.autoswitch-profile" = true;
            "bluez5.roles" = ["hfp_hf" "hsp_hs" "a2dp_sink"];
            # "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            # "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          };
        };
        # configPackages = [
        #   (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
        #     bluez_monitor.properties = {
        #       ["bluez5.enable-sbc-xq"] = true,
        #       ["bluez5.enable-msbc"] = true,
        #       ["bluez5.enable-hw-volume"] = true,
        #       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        #     }
        #   '')
        # ];
      };

      pulse = mkIf cfg.pulse.enable {
        enable = true;
      };
      # NOTE: need to update if I want to use again
      # config.pipewire-pulse = mkIf cfg.pulse.enable {
      #   "context.properties" = {
      #     "log.level" = 2;
      #   };
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-rtkit";
      #       args = {
      #         "nice.level" = -15;
      #         "rt.prio" = 88;
      #         "rt.time.soft" = 200000;
      #         "rt.time.hard" = 200000;
      #       };
      #       flags = [ "ifexists" "nofail" ];
      #     }
      #     { name = "libpipewire-module-protocol-native"; }
      #     { name = "libpipewire-module-client-node"; }
      #     { name = "libpipewire-module-adapter"; }
      #     { name = "libpipewire-module-metadata"; }
      #     {
      #       name = "libpipewire-module-protocol-pulse";
      #       args = {
      #         "pulse.min.req" = "32/48000";
      #         "pulse.default.req" = "32/48000";
      #         "pulse.max.req" = "32/48000";
      #         "pulse.min.quantum" = "32/48000";
      #         "pulse.max.quantum" = "32/48000";
      #         "server.address" = [ "unix:native" ];
      #       };
      #     }
      #   ];
      #   "stream.properties" = {
      #     "node.latency" = "32/48000";
      #     "resample.quality" = 1;
      #   };
      # };
    };
  };
}
