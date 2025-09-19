localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    mkIf
    mkOption
    types
    ;
  cfg = config.services.yubikey-touch-detector;
in
{
  ##### interface
  options.services.yubikey-touch-detector = {
    enable = mkOption {
      description = "Whether to enable yubikey-touch-detector.";
      default = false;
      type = types.bool;
    };

    enableSocket = mkOption {
      description = "Enable socket activation service";
      default = true;
      type = types.bool;
    };

    debug = mkOption {
      description = "Enable verbose logging";
      default = false;
      type = types.bool;
    };

    libNotify = mkOption {
      description = "Send notifications using libnotify";
      default = true;
      type = types.bool;
    };

    enableLog = mkOption {
      description = "Print logs to stdout, collected in journal logs";
      default = true;
      type = types.bool;
    };

    extraConfig = mkOption {
      description = "Extra configuration to add to service.conf";
      default = "";
      type = types.str;
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    xdg.configFile."yubikey-touch-detector/service.conf".text = ''
      # enable debug logging
      YUBIKEY_TOUCH_DETECTOR_VERBOSE=${if cfg.debug then "true" else "false"}

      # show desktop notifications using libnotify
      YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=${if cfg.libNotify then "true" else "false"}

      # do not print notifications to stdout
      YUBIKEY_TOUCH_DETECTOR_STDOUT=${if cfg.enableLog then "true" else "false"}

      # disable Un*x socket notifier
      YUBIKEY_TOUCH_DETECTOR_NOSOCKET=${if cfg.enableSocket then "false" else "true"}

      ${cfg.extraConfig}
    '';

    home.packages = with pkgs; [
      yubikey-touch-detector
    ];

    systemd.user.services.yubikey-touch-detector = {
      Unit.Description = "Detects when your YubiKey is waiting for a touch";
      Unit.Requires = [ "yubikey-touch-detector.socket" ];
      Install.WantedBy = [ "default.target" ];
      Install.Also = mkIf cfg.enableSocket [ "yubikey-touch-detector.socket" ];
      Service = {
        ExecStart = "${getExe pkgs.yubikey-touch-detector}";
        EnvironmentFile = "-%E/yubikey-touch-detector/service.conf";
      };
    };

    systemd.user.sockets = mkIf cfg.enableSocket {
      yubikey-touch-detector = {
        Unit.Description = "Unix socket activation for YubiKey touch detector service";
        Install.WantedBy = [ "sockets.target" ];
        Socket = {
          ListenStream = "%t/yubikey-touch-detector.socket";
          RemoveOnStop = "yes";
        };
      };
    };

  };
}
