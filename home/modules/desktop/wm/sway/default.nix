args @ {self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
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
  cfg = wcfg.sway;
  opts = self.inputs.extra-lib.lib.options;
in {
  imports = [
    (import ./swayr.nix args)
    (import ./swaylock.nix args)
    (import ./full.nix args)
  ];

  options.khome.desktop.wm.sway = {
    enable = opts.enable "enable sway config";
    enableDefaults = opts.enableTrue "enable default shared config";
    startup = mkOption {
      default = [
        {
          command = "systemctl --user daemon-reload";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP";
          always = true;
        }
      ];
      description = "startup commands";
      type = with types; listOf raw;
    };
    keybindings = mkOption {
      type = with types; attrsOf str;
      default = {};
      description = "sway specific keybindings";
    };
    extraPackages = mkOption {
      default = with pkgs; [
        swayidle # autolock
        wdisplays # display management
        wl-clipboard # clipboard mgmt

        # screenshots/recording
        sway-contrib.grimshot # screenshots
        flameshot
        fuzzel # rofi-like
      ];
      description = "extra packages required by sway";
      type = with types; listOf package;
    };
    sessionVariables = mkOption {
      default = {};
      apply = recursiveUpdate {
        MOZ_ENABLE_WAYLAND = 1;
        # set this in tuigreet to not clash
        # XDG_CURRENT_DESKTOP = "sway";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        NIXOS_OZONE_WL = "1"; # sets all electron apps to use Wayland/Ozone
      };
      type = with types; attrsOf (oneOf [str int]);
      description = "session variables for sway";
    };
    enableSystemd = opts.enableTrue "enable system integration";
    enableSwaymsg = opts.enableTrue "enable swaynag integration";
    enableGtk = opts.enableTrue "enable gtk";
    input = opts.raw {
      "*" = {
        xkb_layout = "gb";
        xkb_options = "caps:escape";
      };
    } "inputs option";
    bars = mkOption {
      type = with types; listOf raw;
      default = wcfg.bars;
      description = "shared bars";
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.extraPackages;
    home.sessionVariables = cfg.sessionVariables;
    xdg.configFile."sway/env".text = concatStringsSep "\n" (mapAttrsToList (env: val: "${env}=${toString val}") config.home.sessionVariables);

    stylix.targets.sway.enable = true;
    wayland.windowManager.sway = {
      enable = true;
      checkConfig = false; # for now, breaks with colorscheme variables
      systemd.enable = cfg.enableSystemd;
      swaynag.enable = cfg.enableSwaymsg;
      extraConfig = mkIf cfg.enableDefaults wcfg.sharedExtraConfig;
      extraConfigEarly = mkBefore ''
        set $mod ${config.wayland.windowManager.sway.config.modifier}
      '';
      wrapperFeatures.gtk = mkIf cfg.enableGtk true;
      config = mkMerge [
        (mkIf cfg.enableDefaults wcfg.sharedConfig)
        {
          inherit
            (cfg)
            bars
            startup
            keybindings
            input
            ;
        }
      ];
    };
    # xsession.windowManager.i3 = { inherit config extraConfig; };
  };
}