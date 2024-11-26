# width issue: https://github.com/elkowar/eww/issues/1110
args:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.eww-hyprland;

  reload_script = pkgs.writeShellScript "reload_eww" ''
    windows=$(eww windows | rg '\*' | tr -d '*')

    systemctl --user restart eww.service

    echo $windows | while read -r w; do
      eww open $w
    done
  '';
in
{
  options.programs.eww-hyprland = {
    enable = lib.mkEnableOption "eww Hyprland config";
    systemd = lib.mkEnableOption "enable systemd user";

    configDir = mkOption {
      type = types.path;
      default = ./.;
      example = literalExpression "./eww-config-dir";
      description = ''
        The directory that gets symlinked to
        {file}`$XDG_CONFIG_HOME/eww`.
      '';
    };

    extraPackages = mkOption {
      type = with types; listOf package;
      default =
        (with pkgs; [
          brightnessctl
          coreutils
          iwd
          iwgtk
          jaq
          jc
          nushell
          pamixer
          upower
        ])
        ++ [
          cfg.package
        ];
      description = "packages to add to home packages + systemd unit";
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      default = pkgs.eww;
      defaultText = lib.literalExpression "pkgs.eww";
      description = "Eww package to use.";
    };

    autoReload = lib.mkOption {
      type = lib.types.bool;
      default = false;
      defaultText = lib.literalExpression "false";
      description = "Whether to restart the eww daemon and windows on change.";
    };

    colors = lib.mkOption {
      type = with lib.types; nullOr lines;
      default = null;
      defaultText = lib.literalExpression "null";
      description = ''
        SCSS file with colors defined in the same way as Catppuccin colors are,
        to be used by eww.

        Defaults to Catppuccin Mocha.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.extraPackages;

    # remove nix files
    xdg.configFile."eww" = {
      source = lib.cleanSourceWith {
        filter =
          name: _type:
          let
            baseName = baseNameOf (toString name);
          in
          !(lib.hasSuffix ".nix" baseName) && (baseName != "_colors.scss");
        src = lib.cleanSource cfg.configDir;
      };

      # links each file individually, which lets us insert the colors file separately
      recursive = true;

      onChange = if cfg.autoReload then reload_script.outPath else "";
    };

    # colors file
    xdg.configFile."eww/css/_colors.scss".text =
      if cfg.colors != null then cfg.colors else (builtins.readFile "${cfg.configDir}/css/_colors.scss");

    systemd.user.services.eww = {
      Unit = {
        Description = "Eww Daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath cfg.extraPackages}";
        ExecStart = "${cfg.package}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
        Type = "simple";
        ReadOnlyPaths = [ "/home/%u/.config/eww" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
