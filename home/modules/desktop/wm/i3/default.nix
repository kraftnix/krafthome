{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    mkBefore
    mkIf
    mkMerge
    mkOption
    recursiveUpdate
    types
    ;
  wcfg = config.khome.desktop.wm;
  cfg = wcfg.i3;
  opts = self.inputs.extra-lib.lib.options;
in
{
  options.khome.desktop.wm.i3 = {
    enable = opts.enable "enable i3 config";
    enableDefaults = opts.enableTrue "enable default shared config";
    startup = mkOption {
      default = [
        {
          command = "systemctl --user daemon-reload";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd DISPLAY XDG_CURRENT_DESKTOP";
          always = true;
        }
        {
          command = "volumeicon";
          notification = false;
        }
        {
          command = "xautolock -time 10 -locker blurlock";
          notification = false;
        }
      ];
      description = "startup commands";
      type = with types; listOf raw;
    };
    keybindings = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "i3 specific keybindings";
    };
    extraPackages = mkOption {
      default = with pkgs; [
        i3lock # lock
        flameshot # screenshots
        lxappearance # gtk theming
      ];
      description = "extra packages required by i3";
      type = with types; listOf package;
    };
    sessionVariables = mkOption {
      default = { };
      apply = recursiveUpdate {
        MOZ_ENABLE_WAYLAND = 1;
        # set this in tuigreet to not clash
        # XDG_CURRENT_DESKTOP = "i3";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        NIXOS_OZONE_WL = "1"; # sets all electron apps to use Wayland/Ozone
      };
      type =
        with types;
        attrsOf (oneOf [
          str
          int
        ]);
      description = "session variables for i3";
    };
    enableSystemd = opts.enableTrue "enable system integration";
    enablei3msg = opts.enableTrue "enable i3nag integration";
    enableGtk = opts.enableTrue "enable gtk";
    inputs = opts.raw {
      "*" = {
        xkb_layout = "gb";
        xkb_options = "caps:escape";
      };
    } "inputs option";
    bars = mkOption {
      type = with types; listOf raw;
      default = wcfg.bars;
      example = [
        {
          fonts = wcfg.fonts;
          position = "top";
          extraConfig = ''
            bindsym button4 nop
            bindsym button5 nop
          '';
          #colors = common.config.colors;
        }
      ];
      description = "shared bars";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.extraPackages;
    home.sessionVariables = cfg.sessionVariables;
    xdg.configFile."i3/env".text = concatStringsSep "\n" (
      mapAttrsToList (env: val: "${env}=${toString val}") config.home.sessionVariables
    );

    xsession.windowManager.i3 = {
      enable = true;
      config = mkMerge [
        (mkIf cfg.enableDefaults wcfg.sharedConfig)
        {
          inherit (cfg)
            bars
            startup
            ;
          # inherit (wcfg)
          #   modifier
          #   terminal
          #   fonts
          #   menu
          #   gaps
          #   modes
          #   left
          #   right
          #   up
          #   down
          #   ;
          keybindings = {
            Print = "exec --no-startup-id i3-scrot";
            "$mod+Print" = "exec flameshot gui";
            # hide/unhide i3status bar
            "$mod+m" = "bar mode toggle";
          } // cfg.keybindings;
        }
      ];
      extraConfig = mkMerge [
        (mkIf cfg.enableDefaults wcfg.sharedExtraConfig)
        (mkBefore "set $mod ${config.xsession.windowManager.i3.config.modifier}")
      ];
    };
    # xsession.windowManager.i3 = { inherit config extraConfig; };
  };
}
