{
  config,
  lib,
  ...
}:
{
  services.pipewire = lib.mkIf config.khome.sound.pipewire.media-session.enable {
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    wireplumber.enable = lib.mkForce false;
    media-session.enable = true;
    # TODO: need to update if I want to use media-session again
    # media-session.config.bluez-monitor.rules = [
    #   {
    #     # Matches all cards
    #     matches = [{ "device.name" = "~bluez_card.*"; }];
    #     actions = {
    #       "update-props" = {
    #         "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
    #         # mSBC is not expected to work on all headset + adapter combinations.
    #         "bluez5.msbc-support" = true;
    #         # SBC-XQ is not expected to work on all headset + adapter combinations.
    #         "bluez5.sbc-xq-support" = true;
    #       };
    #     };
    #   }
    #   {
    #     matches = [
    #       # Matches all sources
    #       { "node.name" = "~bluez_input.*"; }
    #       # Matches all outputs
    #       { "node.name" = "~bluez_output.*"; }
    #     ];
    #     actions = {
    #       "node.pause-on-idle" = false;
    #     };
    #   }
    # ];
  };
}
