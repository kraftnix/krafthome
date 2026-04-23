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
  cfg = config.khome.desktop.awww;
  wallpaperDirs = concatStringsSep " " cfg.wallpaperDirs;
  singleRandom = "awww-randomise -i 0 ${wallpaperDirs}";
  startAndRandom =
    if cfg.systemdIntegration then
      # "systemctl --user start awww && ${singleRandom}"
      "systemctl --user restart awww && systemctl --user restart awww-rotate"
    else
      "awww-daemon init && ${singleRandom}";
  randomiseCommand = "awww-randomise -i ${toString cfg.interval} -f ${toString cfg.fps} ${
    optionalString (cfg.transitionType != null) "-t ${cfg.transitionType}"
  } -s ${toString cfg.step} ${wallpaperDirs}";
  randomisePackage = config.provision.scripts.scripts.awww-randomise.package;
in
{
  options.khome.desktop.awww = {
    enable = mkEnableOption "enable awww wallpapers";
    systemdIntegration = mkEnableOption "enable systemd user service";
    step = mkOption {
      default = 2;
      type = types.int;
      description = "corresponds to awww_TRANSITION_STEP";
    };
    fps = mkOption {
      default = 60;
      type = types.int;
      description = "corresponds to awww_TRANSITION_FPS";
    };
    interval = mkOption {
      default = 60;
      type = types.int;
      description = "time interval in seconds between wallpaper changes";
    };
    transitionType = mkOption {
      default = "simple";
      type = with types; str;
      description = "optional `transition-type` argument to `awww`";
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
    keybind = mkOption {
      type = types.str;
      default = "i";
      description = "hyprland mod key (with $mod + shift)";
    };
  };

  config = mkIf cfg.enable {

    khome.desktop.wm.shared.binds.awww-next = {
      enable = true;
      exec = true;
      mapping = cfg.keybind;
      command = singleRandom;
      extraKeys = mkIf cfg.enableShift [ "Shift" ];
    };

    programs.hyprland.execOnce = {
      "awww-init" = startAndRandom;
      "awww-randomise" = mkIf (!cfg.systemdIntegration) randomiseCommand;
    };

    wayland.windowManager.sway.config.startup = lib.mkAfter (
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

    provision.scripts.scripts.awww-randomise.file = ./awww-randomise.nu;

    home.packages = [ pkgs.awww ];

    systemd.user.services.awww = mkIf cfg.systemdIntegration {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "awww Wallpaper Daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        RemainAfterExit = true;
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
      };
    };

    systemd.user.services.awww-rotate = mkIf cfg.systemdIntegration {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "awww Wallpaper Rotate Service";
        After = [ "awww.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = [
          "PATH=${
            lib.makeBinPath [
              pkgs.fd
              pkgs.awww
            ]
          }"
        ]
        ++ (optional (cfg.fps != null) "awww_TRANSITION_FPS=${toString cfg.fps}")
        ++ (optional (cfg.step != null) "awww_TRANSITION_STEP=${toString cfg.step}")
        ++ (optional (cfg.transitionType != null) "awww_TRANSITION_TYPE=${cfg.transitionType}");
        Restart = "on-failure";
        ExecStart = "${randomisePackage}/bin/${randomiseCommand}";
      };
    };
  };
}
