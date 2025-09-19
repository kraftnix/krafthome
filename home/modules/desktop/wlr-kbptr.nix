localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;
  cfg = config.programs.wl-kbptr;
in
{
  ##### interface
  options.programs.wl-kbptr = {
    enable = mkOption {
      description = "Whether to enable wl-kbptr completion.";
      default = false;
      type = types.bool;
    };
  };

  ##### implementation
  config = mkIf cfg.enable {
    home.packages = [ pkgs.wl-kbptr ];

    khome.desktop.wm.shared.binds = {
      mouse_mode = {
        enable = true;
        mapping = "f";
        extraKeys = [ "Shift" ];
        sway.command = "mode Mouse";
        hyprland.enable = false; # TODO: implement
        hyprland.command = "submap,mouse";
        niri.enable = false;
      };
      float_click = {
        enable = true;
        exec = true;
        mapping = "a";
        command = "wl-kbptr -o modes=floating,click -o mode_floating.source=detect";
      };
      float = {
        enable = true;
        exec = true;
        mapping = "a";
        command = "wl-kbptr -o modes=floating -o mode_floating.source=detect";
        extraKeys = [ "Shift" ];
      };
    };

    # NOTE: can't move this into modes since --release keybinds aren't supported there
    wayland.windowManager.sway.extraConfig = ''
      mode Mouse {
        bindsym a mode default, exec 'wl-kbptr-sway-active-win; swaymsg mode Mouse'
        bindsym Shift+a mode default, exec 'wl-kbptr; swaymsg mode Mouse'

        # Mouse move
        bindsym h seat seat0 cursor move -15 0
        bindsym j seat seat0 cursor move 0 15
        bindsym k seat seat0 cursor move 0 -15
        bindsym l seat seat0 cursor move 15 0

        # Left button
        bindsym s seat seat0 cursor press button1
        bindsym --release s seat seat0 cursor release button1

        # Middle button
        bindsym d seat seat0 cursor press button2
        bindsym --release d seat seat0 cursor release button2

        # Right button
        bindsym f seat seat0 cursor press button3
        bindsym --release f seat seat0 cursor release button3

        bindsym Escape mode default
      }
    '';

  };
}
