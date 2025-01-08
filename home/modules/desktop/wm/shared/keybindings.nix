args:
{
  config,
  lib,
  ...
}:
let
  cfg = config.khome.desktop.wm;
  sharedKeybindings = lib.mapAttrs (n: lib.mkDefault) {
    "$mod+Return" = "exec ${cfg.terminal}";
    "$mod+Shift+q" = "kill";
    "$mod+d" = "exec ${cfg.menu}";

    "$mod+${cfg.left}" = "focus left";
    "$mod+${cfg.down}" = "focus down";
    "$mod+${cfg.up}" = "focus up";
    "$mod+${cfg.right}" = "focus right";

    "$mod+Left" = "focus left";
    "$mod+Down" = "focus down";
    "$mod+Up" = "focus up";
    "$mod+Right" = "focus right";

    "$mod+Shift+${cfg.left}" = "move left";
    "$mod+Shift+${cfg.down}" = "move down";
    "$mod+Shift+${cfg.up}" = "move up";
    "$mod+Shift+${cfg.right}" = "move right";

    "$mod+Shift+Left" = "move left";
    "$mod+Shift+Down" = "move down";
    "$mod+Shift+Up" = "move up";
    "$mod+Shift+Right" = "move right";

    "$mod+b" = "splith";
    "$mod+v" = "splitv";
    "$mod+f" = "fullscreen toggle";
    "$mod+x" = "focus parent";

    "$mod+s" = "layout stacking";
    "$mod+w" = "layout tabbed";
    "$mod+e" = "layout toggle split";

    "$mod+Shift+space" = "floating toggle";
    "$mod+space" = "focus mode_toggle";

    "$mod+1" = "workspace number 1";
    "$mod+2" = "workspace number 2";
    "$mod+3" = "workspace number 3";
    "$mod+4" = "workspace number 4";
    "$mod+5" = "workspace number 5";
    "$mod+6" = "workspace number 6";
    "$mod+7" = "workspace number 7";
    "$mod+8" = "workspace number 8";
    "$mod+9" = "workspace number 9";

    "$mod+Shift+1" = "move container to workspace number 1";
    "$mod+Shift+2" = "move container to workspace number 2";
    "$mod+Shift+3" = "move container to workspace number 3";
    "$mod+Shift+4" = "move container to workspace number 4";
    "$mod+Shift+5" = "move container to workspace number 5";
    "$mod+Shift+6" = "move container to workspace number 6";
    "$mod+Shift+7" = "move container to workspace number 7";
    "$mod+Shift+8" = "move container to workspace number 8";
    "$mod+Shift+9" = "move container to workspace number 9";

    "$mod+Shift+minus" = "move scratchpad";
    "$mod+minus" = "scratchpad show";

    "$mod+Shift+c" = "reload";
    "$mod+Shift+e" =
      "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

    "$mod+r" = "mode resize";
  };
in
{
  khome.desktop.wm.keybindings = sharedKeybindings;
}
