args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.khome.desktop.swayidle;
  command = pkgs.writeScript "outputs_off.nu" ''
    #!/usr/bin/env nu

    def main [ switch ] {
      if ($env | get -i HYPRLAND_INSTANCE_SIGNATURE) != null {
        hyprctl dispatch dpms $switch
      } else {
        swaymsg $"output * dpms ($switch)"
      }
    }
  '';
in {
  options.khome.desktop.swayidle = {
    enable = mkEnableOption "enable swayidle integration";
    lockTimeout = mkOption {
      description = "time until screen lock (seconds), default 5mins";
      default = 300;
      type = types.int;
    };
    screenOffTimeout = mkOption {
      description = "time after lock, until screen turns off (seconds), default 10mins";
      default = 600;
      type = types.int;
    };
    swayStartupCommand = mkOption {
      description = ''
        sway startup command that can be run instead of systemd unit.
        can be added to `wayland.windowManager.sway.config.startup.*.command`
      '';
      default = "swayidle";
      type = with types; oneOf [str package];
      readOnly = true;
    };
    appendToSwayConfig = mkEnableOption ''
      Automatically append the swayidle command to `home-manager`'s sway configuration.
    '';
    appendToHyprlandConfig = mkEnableOption ''
      Automatically append the swayidle command to `home-manager`'s sway configuration.
    '';
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [swaylock libnotify nushell];
      description = "extra packages to provide to systemd service or add to home path";
    };
  };

  config = mkIf cfg.enable {
    khome.desktop.swayidle.swayStartupCommand = mkDefault config.systemd.user.services.swayidle.Service.ExecStart;
    # TODO: find way to disable systemd user unit when this option is enabled.
    wayland.windowManager.sway.config.startup = mkIf cfg.appendToSwayConfig [
      {
        always = true;
        command = cfg.swayStartupCommand;
      }
    ];
    programs.hyprland.execOnce.swayidle = cfg.swayStartupCommand;
    systemd.user.services.swayidle.Service.Environment = lib.mkForce ["PATH=${lib.makeBinPath ([pkgs.bash] ++ cfg.extraPackages)}"];
    home.packages = lib.mkIf cfg.appendToSwayConfig cfg.extraPackages;
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = cfg.lockTimeout - 10;
          command = ''notify-send -t 10000 "Screen lock in 10 seconds"'';
        }
        {
          timeout = cfg.lockTimeout;
          command = "swaylock -fF";
        }
        {
          timeout = cfg.screenOffTimeout + cfg.lockTimeout;
          command = "${command} off";
          resumeCommand = "${command} on";
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = "swaylock -fF";
        }
        {
          event = "lock";
          command = "swaylock -fF";
        }
      ];
    };
  };
}
