args:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkAfter
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    types
    ;
  cfg = config.khome.desktop.swww;
  wallpaperDirs = concatStringsSep " " cfg.wallpaperDirs;
  singleRandom = "swww-randomise -i 0 ${wallpaperDirs}";
  startAndRandom =
    if cfg.systemdIntegration then
      # "systemctl --user start swww && ${singleRandom}"
      "systemctl --user restart swww && systemctl --user restart swww-rotate"
    else
      "swww-daemon init && ${singleRandom}";
  randomiseCommand = "swww-randomise -i ${toString cfg.interval} -f ${toString cfg.fps} ${
    optionalString (cfg.transitionType != null) "-t ${cfg.transitionType}"
  } -s ${toString cfg.step} ${wallpaperDirs}";
  randomisePackage = config.provision.scripts.scripts.swww-randomise.package;
in
{
  options.khome.desktop.swww = {
    enable = mkEnableOption "enable swww wallpapers";
    systemdIntegration = mkEnableOption "enable systemd user service";
    step = mkOption {
      default = 2;
      type = types.int;
      description = "corresponds to SWWW_TRANSITION_STEP";
    };
    fps = mkOption {
      default = 60;
      type = types.int;
      description = "corresponds to SWWW_TRANSITION_FPS";
    };
    interval = mkOption {
      default = 60;
      type = types.int;
      description = "time interval in seconds between wallpaper changes";
    };
    transitionType = mkOption {
      default = "simple";
      type = with types; str;
      description = "optional `transition-type` argument to `swww`";
    };
    wallpaperDirs = mkOption {
      default = optional config.khome.themes.enable config.khome.themes.images.wallpaperDir;
      type = types.listOf types.str;
      description = "directories to source wallpapers from, matches png and jpg";
    };
    enableShift = mkOption {
      type = types.bool;
      default = true;
      description = "add shift key to hyprand/sway mapping";
    };
    hyprlandKey = mkOption {
      type = types.str;
      default = "I";
      description = "hyprland mod key (with $mod + shift)";
    };
    swayKey = mkOption {
      type = types.str;
      default = "$mod${optionalString cfg.enableShift "+Shift"}+i";
      description = "sway mod key (with $mod + shift)";
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      binds."$mod${optionalString cfg.enableShift " SHIFT"}".${cfg.hyprlandKey} = "exec, ${singleRandom}";
      execOnce = {
        "swww-init" = startAndRandom;
        "swww-randomise" = mkIf (!cfg.systemdIntegration) randomiseCommand;
      };
    };

    wayland.windowManager.sway.config = {
      keybindings."${cfg.swayKey}" = lib.mkOverride 250 "exec ${singleRandom}";
      startup = lib.mkAfter (
        [
          {
            command = startAndRandom;
            always = cfg.systemdIntegration;
          }
        ]
        ++ (optional (!cfg.systemdIntegration) {
          command = randomiseCommand;
          always = cfg.systemdIntegration;
        })
      );
    };

    provision.scripts.scripts.swww-randomise.file = ./swww-randomise.nu;

    home.packages = [ pkgs.swww ];

    systemd.user.services.swww = mkIf cfg.systemdIntegration {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "SWWW Wallpaper Daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        RemainAfterExit = true;
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
      };
    };

    systemd.user.services.swww-rotate = mkIf cfg.systemdIntegration {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "SWWW Wallpaper Rotate Service";
        After = [ "swww.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = [
          "PATH=${
            lib.makeBinPath [
              pkgs.fd
              pkgs.swww
            ]
          }"
        ]
        ++ (optional (cfg.fps != null) "SWWW_TRANSITION_FPS=${toString cfg.fps}")
        ++ (optional (cfg.step != null) "SWWW_TRANSITION_STEP=${toString cfg.step}")
        ++ (optional (cfg.transitionType != null) "SWWW_TRANSITION_TYPE=${cfg.transitionType}");
        Restart = "on-failure";
        ExecStart = "${randomisePackage}/bin/${randomiseCommand}";
      };
    };
  };
}
