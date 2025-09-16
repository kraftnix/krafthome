args@{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.wm;
  opts = self.inputs.extra-lib.lib.options;
  shared = {
    config = cfg.sharedConfig;
    extraConfig = cfg.sharedExtraConfig;
  };
in
{
  imports = [
    (import ./extended.nix args)
    (import ./keybindings.nix args)
    (import ./legacy-theme.nix args)
    (import ./lock_mode.nix args)
  ];

  options.khome.desktop.wm = {
    sharedConfig = opts.raw { } "shared config to apply to all window managers";
    sharedExtraConfig = opts.string "" "extra config to apply to all window managers";

    modifier = opts.string "Mod4" "wm modifier key";
    terminal = opts.string "wezterm" "wm modifier key";
    backAndForth = {
      enable = opts.enableTrue "enable workspaceAutoBackAndForth: back and forth (with/without active container)";
      key = opts.string "$mod+Tab" "keybind for back and forth";
    };
    fonts = opts.raw {
      # only works for hm atm
      # names = [ config.themes.font.fontSizeStr ];
      names = [ "Fira Code Nerd Font Mono" ];
      style = "Bold Semi-Condensed";
      size = lib.mkDefault config.stylix.fonts.sizes.desktop;
    } "fonts for window manager";
    menu = opts.string "fuzzel --show-actions" "command runner command" // {
      example = ''"rofi -show-icons -modi ssh,drun,filebrowser,emoji -show drun"'';
    };
    gaps.enable = opts.enableTrue "enable gaps configuration";
    focus = opts.raw {
      newWindow = "urgent";
      followMouse = "always";
    } "focus options";
    modes = {
      resize = {
        enable = opts.enableTrue "enable resize mode";
        key = opts.string "" "key for resize mode";
      };
    };
    keybindings = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "shared keybindings";
    };
    bars = mkOption {
      type = with types; listOf raw;
      default = [ ];
      description = "shared bars";
    };
    brightness = {
      enable = opts.enableTrue "enable brightness key settings";
      increment = opts.int 5 "increment/decrement percent";
      upCommand = opts.string "brightnessctl set ${toString cfg.volume.increment}+% && notify-send 'brightness up'" "command to set when brightness up pressed";
      downCommand = opts.string "brightnessctl set ${toString cfg.volume.increment}-% && notify-send 'brightness down'" "command to set when brightness down pressed";
      minCommand = opts.string "brightnessctl set 1% && notify-send 'brightness low'" "command to set when shift+brightness down pressed";
    };
    volume = {
      enable = opts.enableTrue "enable volume key settings";
      increment = opts.int 5 "increment/decrement percent";
      raise = opts.string "--no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +${toString cfg.volume.increment}%" "increase volume via volume up key";
      lower = opts.string "--no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -${toString cfg.volume.increment}%" "reduce volume via volume down key";
      mute = opts.string "--no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle" "toggle mute";
    };
    media = {
      enable = opts.enableTrue "enable media key settings";
      nextCommand = opts.string "--no-startup-id ${pkgs.playerctl}/bin/playerctl next" "command to play next song";
      prevCommand = opts.string "--no-startup-id ${pkgs.playerctl}/bin/playerctl previous" "command to play prev song";
      pausePlayCommand = opts.string "--no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause" "command to toggle play/pause";
    };
    left = opts.string "h" "left";
    right = opts.string "l" "right";
    up = opts.string "k" "up";
    down = opts.string "j" "down";
  };

  config = {
    wayland.windowManager.sway = shared;
    xsession.windowManager.i3 = shared;

    khome.desktop.wm.keybindings = {
      # makes floating window stick across workspace changes
      "$mod+Shift+s" = "sticky toggle";

      # navigate workspaces next / previous
      "$mod+Ctrl+Right" = "workspace next";
      "$mod+Ctrl+Left" = "workspace prev";

      # move workspace across monitors
      "$mod+Ctrl+Shift+h" = "move workspace to output left";
      "$mod+Ctrl+Shift+j" = "move workspace to output down";
      "$mod+Ctrl+Shift+k" = "move workspace to output up";
      "$mod+Ctrl+Shift+l" = "move workspace to output right";
    };

    khome.desktop.wm.sharedExtraConfig = mkIf cfg.legacyTheme.enable cfg.legacyTheme.extraConfig;
    khome.desktop.wm.sharedConfig = {
      inherit (cfg)
        modifier
        terminal
        fonts
        menu
        left
        right
        up
        down
        ;
      workspaceAutoBackAndForth = cfg.backAndForth.enable;
      keybindings = mkMerge [
        (mkIf cfg.backAndForth.enable {
          ${cfg.backAndForth.key} = mkDefault "workspace back_and_forth";
        })
        (mkIf cfg.brightness.enable {
          # bind brightnessctl to function keys
          "XF86MonBrightnessUp" = "exec ${cfg.brightness.upCommand}";
          "XF86MonBrightnessDown" = "exec ${cfg.brightness.downCommand}";
          "Shift+XF86MonBrightnessDown" = "exec ${cfg.brightness.minCommand}";
        })
        (mkIf cfg.media.enable {
          # start/stop/next/prev via playerctl
          "XF86AudioPlay" = "exec ${cfg.media.pausePlayCommand}";
          "XF86AudioNext" = "exec ${cfg.media.nextCommand}";
          "XF86AudioPrev" = "exec ${cfg.media.prevCommand}";
        })
        (mkIf cfg.volume.enable {
          # Set volume via pulse audio controls
          "XF86AudioRaiseVolume" = "exec ${cfg.volume.raise}";
          "XF86AudioLowerVolume" = "exec ${cfg.volume.lower}";
          "XF86AudioMute" = "exec ${cfg.volume.mute}";
        })
        # bind brightnessctl to function keys
        (mapAttrs (_: mkDefault) cfg.keybindings)
      ];
      gaps = mkIf cfg.gaps.enable {
        inner = mkDefault 14;
        outer = mkDefault (-2);
        smartGaps = mkDefault true;
        smartBorders = mkDefault "no_gaps";
      };
      modes = {
        resize = mkIf cfg.modes.resize.enable {
          # escape modes
          Escape = "mode default";
          Return = "mode default";
          # arrow keys resize
          Up = "resize shrink height 10 px";
          Down = "resize grow height 10 px";
          Left = "resize shrink width 10 px";
          Right = "resize grow width 10 px";
          # hjkl resize
          k = "resize shrink height 10 px";
          j = "resize grow height 10 px";
          h = "resize shrink width 10 px";
          l = "resize grow width 10 px";
        };
      };
    };
  };
}
