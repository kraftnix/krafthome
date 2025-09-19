{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.desktop.wm;
  inherit (lib) mkIf;
in
{
  khome.desktop.wm.shared.enableBinds = true;
  khome.desktop.wm.shared.binds = {
    terminal = {
      exec = true;
      mapping = "Return";
      command = cfg.terminal;
      niri.output.hotkey-overlay.title = "Open a Terminal: ${cfg.terminal}";
    };
    fullscreen = {
      enable = true;
      mapping = "f";
      sway.command = "fullscreen toggle";
      hyprland.command = "fullscreen";
      niri.output.action = config.lib.niri.actions.fullscreen-window;
      niri.output.hotkey-overlay.title = "Fullscreen current window";
    };
    picker = {
      exec = true;
      mapping = "d";
      command = cfg.menu;
      niri.output.hotkey-overlay.title = "Run an application via: ${cfg.menu}";
    };
    emoji = {
      exec = true;
      mapping = "g";
      command = "rofi -show emoji -modi emoji";
      niri.output.hotkey-overlay.title = "Select (and copy) an emoji";
    };
    opacity = {
      enable = true;
      exec = true;
      mapping = "o";
      hyprland.command = "hyprctl setprop active opaque toggle";
      sway.command = "${pkgs.writers.writeNu "toggle_opacity.nu" ''
        let i = (swaymsg opacity plus 0.01 | complete)
        if $i.exit_code != 0 {
          # was opaque, make transparent
          swaymsg opacity 0.95
        } else {
          # was transparent, make opaque
          swaymsg opacity 1
        }
      ''}";
      niri.output.action = config.lib.niri.actions.toggle-window-rule-opacity;
      niri.output.hotkey-overlay.title = "Toggle opacity";
    };
    reload_hard = {
      enable = true;
      exec = true;
      mapping = "r";
      extraKeys = [ "Shift" ];
      hyprland.command = "${pkgs.writers.writeNu "reload-hyprland.nu" ''
        hyprctl reload
        ${cfg.reloadScript}
      ''}";
      sway.command = "${pkgs.writers.writeNu "reload-sway.nu" ''
        swaymsg reload
        ${cfg.reloadScript}
      ''}";
      niri.command = "${pkgs.writers.writeNu "reload-niri.nu" ''
        ${cfg.reloadScript}
      ''}";
      niri.output.hotkey-overlay.title = "Hard reload services";
    };
    workspace_back_and_forth = mkIf cfg.backAndForth.enable {
      enable = true;
      mapping = cfg.backAndForth.key;
      sway.command = "workspace back_and_forth";
      hyprland.command = "workspace, previous";
      niri.output.action = config.lib.niri.actions.focus-workspace-previous;
      niri.output.hotkey-overlay.title = "Go to last workspace";
    };

    ## Brightness: bind brightnessctl to function keys
    brightness_up = mkIf cfg.brightness.enable {
      exec = true;
      mod = false;
      mapping = "XF86MonBrightnessUp";
      command = cfg.brightness.upCommand;
      niri.output.hotkey-overlay.title = "Increase brightness [brightness]";
    };
    brightness_down = mkIf cfg.brightness.enable {
      exec = true;
      mod = false;
      mapping = "XF86MonBrightnessDown";
      command = cfg.brightness.downCommand;
      niri.output.hotkey-overlay.title = "Decrease brightness [brightness]";
    };
    brightness_min = mkIf cfg.brightness.enable {
      exec = true;
      mod = false;
      mapping = "XF86MonBrightnessDown";
      command = cfg.brightness.minCommand;
      extraKeys = [ "Shift" ];
      niri.output.hotkey-overlay.title = "Decrease brightness to minimum [brightness]";
    };

    ## Media: start/stop/next/prev via playerctl
    media_play = mkIf cfg.media.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioPlay";
      command = cfg.media.pausePlayCommand;
      niri.output.hotkey-overlay.title = "Play song/video [media]";
    };
    media_next = mkIf cfg.media.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioNext";
      command = cfg.media.nextCommand;
      niri.output.hotkey-overlay.title = "Play next song/video [media]";
    };
    media_prev = mkIf cfg.media.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioPrev";
      command = cfg.media.prevCommand;
      niri.output.hotkey-overlay.title = "Play previous song/video [media]";
    };

    ## Volume
    volume_up = mkIf cfg.volume.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioRaiseVolume";
      command = cfg.volume.raise;
      niri.output.hotkey-overlay.title = "Volume up [volume]";
    };
    volume_down = mkIf cfg.volume.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioLowerVolume";
      command = cfg.volume.lower;
      niri.output.hotkey-overlay.title = "Volume down [volume]";
    };
    volume_mute = mkIf cfg.volume.enable {
      exec = true;
      mod = false;
      mapping = "XF86AudioMute";
      command = cfg.volume.mute;
      niri.output.hotkey-overlay.title = "Toggle Mute [volume]";
    };
  };
}
