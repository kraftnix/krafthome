{
  config,
  lib,
  ...
}:
{
  config.programs.niri.settings.binds =
    with config.lib.niri.actions;
    lib.mkIf config.khome.desktop.wm.niri.enableDefaults (
      lib.mapAttrs (_: lib.mkDefault) {
        "Mod+Shift+Slash" = {
          action = show-hotkey-overlay;
          hotkey-overlay.title = "Show hotkey overlay";
        };

        "Mod+Alt+L" = {
          action = spawn "swaylock";
          hotkey-overlay.title = "Lock the Screen: swaylock";
        };

        "Mod+X" = {
          repeat = false;
          action = toggle-overview;
          hotkey-overlay.title = "Toggle Overview";
        };

        "Mod+Shift+Q" = {
          repeat = false;
          action = close-window;
          hotkey-overlay.title = "Close window";
        };

        # "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        # "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";

        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Shift+1".action.move-window-to-workspace = 1;
        "Mod+Shift+2".action.move-window-to-workspace = 2;
        "Mod+Shift+3".action.move-window-to-workspace = 3;
        "Mod+Shift+4".action.move-window-to-workspace = 4;
        "Mod+Shift+5".action.move-window-to-workspace = 5;
        "Mod+Shift+6".action.move-window-to-workspace = 6;
        "Mod+Shift+7".action.move-window-to-workspace = 7;
        "Mod+Shift+8".action.move-window-to-workspace = 8;
        "Mod+Shift+9".action.move-window-to-workspace = 9;

        "Mod+Shift+E" = {
          action = quit;
          hotkey-overlay.title = "Quit";
        };
        "Mod+Ctrl+Shift+E" = {
          action = quit { skip-confirmation = true; };
          hotkey-overlay.title = "Force Quit";
        };

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+L".action = focus-column-right;

        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Down".action = move-window-down;
        "Mod+Ctrl+Up".action = move-window-up;
        "Mod+Ctrl+Right".action = move-column-right;
        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+J".action = move-window-down-or-to-workspace-down;
        # "Mod+Ctrl+J".action = move-window-down;
        # "Mod+Ctrl+K".action = move-window-up;
        "Mod+Ctrl+K".action = move-window-up-or-to-workspace-up;
        "Mod+Ctrl+L".action = move-column-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;
        "Mod+Shift+Right".action = focus-monitor-right;
        "Mod+Shift+H".action = focus-monitor-left;
        "Mod+Shift+J".action = focus-monitor-down;
        "Mod+Shift+K".action = focus-monitor-up;
        "Mod+Shift+L".action = focus-monitor-right;

        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

        # // Alternatively, there are commands to move just a single window:
        # // Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
        # // ...
        #
        # // And you can also move a whole workspace to another monitor:
        # // Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
        # // ...

        # Mod+Page_Down      { focus-workspace-down; }
        # Mod+Page_Up        { focus-workspace-up; }
        # Mod+U              { focus-workspace-down; }
        # Mod+I              { focus-workspace-up; }
        # Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        # Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
        # Mod+Ctrl+U         { move-column-to-workspace-down; }
        # Mod+Ctrl+I         { move-column-to-workspace-up; }

        # // Alternatively, there are commands to move just a single window:
        # // Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
        # Mod+Shift+Page_Down { move-workspace-down; }
        # Mod+Shift+Page_Up   { move-workspace-up; }
        # Mod+Shift+U         { move-workspace-down; }
        # Mod+Shift+I         { move-workspace-up; }

        # // You can bind mouse wheel scroll ticks using the following syntax.
        # // These binds will change direction based on the natural-scroll setting.
        # //
        # // To avoid scrolling through workspaces really fast, you can use
        # // the cooldown-ms property. The bind will be rate-limited to this value.
        # // You can set a cooldown on any bind, but it's most useful for the wheel.
        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-workspace-down;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-workspace-up;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-down;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action = move-column-to-workspace-up;
        };
        # Mod+WheelScrollRight      { focus-column-right; }
        # Mod+WheelScrollLeft       { focus-column-left; }
        # Mod+Ctrl+WheelScrollRight { move-column-right; }
        # Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        # // Usually scrolling up and down with Shift in applications results in
        # // horizontal scrolling; these binds replicate that.
        "Mod+Shift+WheelScrollDown".action = focus-column-right;
        "Mod+Shift+WheelScrollUp".action = focus-column-left;
        "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
        "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-left;

        # // Similarly, you can bind touchpad scroll "ticks".
        # // Touchpad scrolling is continuous, so for these binds it is split into
        # // discrete intervals.
        # // These binds are also affected by touchpad's natural-scroll, so these
        # // example binds are "inverted", since we have natural-scroll enabled for
        # // touchpads by default.
        # // Mod+TouchpadScrollDown { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+"; }
        # // Mod+TouchpadScrollUp   { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }

        # // Alternatively, there are commands to move just a single window:
        # // Mod+Ctrl+1 { move-window-to-workspace 1; }
        # // Switches focus between the current and the previous workspace.
        "Mod+Tab".action = focus-workspace-previous;
        "Mod+Shift+Tab".action = focus-window-previous;

        # // The following binds move the focused window in and out of a column.
        # // If the window is alone, they will consume it into the nearby column to the side.
        # // If the window is already in a column, they will expel it out.
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        # // Consume one window from the right to the bottom of the focused column.
        "Mod+Comma".action = consume-window-into-column;
        # // Expel the bottom window from the focused column to the right.
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;

        # // Cycling through the presets in reverse order is also possible.
        # // Mod+R { switch-preset-column-width-back; }
        # Mod+Shift+R { switch-preset-window-height; }
        # Mod+Ctrl+R { reset-window-height; }
        # swapped from default
        "Mod+Shift+F".action = maximize-column;

        # // Expand the focused column to space not taken up by other fully visible columns.
        # // Makes the column "fill the rest of the space".
        "Mod+Ctrl+F".action = expand-column-to-available-width;
        "Mod+C".action = center-column;

        # // Center all fully visible columns on screen.
        "Mod+Ctrl+C".action = center-visible-columns;

        # // Finer width adjustments.
        # // This command can also:
        # // * set width in pixels: "1000"
        # // * adjust width in pixels: "-5" or "+5"
        # // * set width as a percentage of screen width: "25%"
        # // * adjust width as a percentage of screen width: "-10%" or "+10%"
        # // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        # // set-column-width "100" will make the column occupy 200 physical screen pixels.
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Plus".action = set-column-width "+10%";

        # // Finer height adjustments when in column with other windows.
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # // Move the focused window between the floating and the tiling layout.
        "Mod+Space".action = toggle-window-floating;
        "Mod+Shift+Space".action = switch-focus-between-floating-and-tiling;

        # // Toggle tabbed column display mode.
        # // Windows in this column will appear as vertical tabs,
        # // rather than stacked on top of each other.
        "Mod+W".action = toggle-column-tabbed-display;

        # // Actions to switch layouts.
        # // Note: if you uncomment these, make sure you do NOT have
        # // a matching layout switch hotkey configured in xkb options above.
        # // Having both at once on the same hotkey will break the switching,
        # // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        # // Mod+Space       { switch-layout "next"; }
        # // Mod+Shift+Space { switch-layout "prev"; }
        "Print".action.screenshot = [ ];
        # "Ctrl+Print".action = screenshot-screen;
        # "Alt+Print".action = screenshot-window;

        # // Applications such as remote-desktop clients and software KVM switches may
        # // request that niri stops processing the keyboard shortcuts defined here
        # // so they may, for example, forward the key presses as-is to a remote machine.
        # // It's a good idea to bind an escape hatch to toggle the inhibitor,
        # // so a buggy application can't hold your session hostage.
        # //
        # // The allow-inhibiting=false property can be applied to other binds as well,
        # // which ensures niri always processes them, even when an inhibitor is active.
        "Mod+Escape" = {
          allow-inhibiting = false;
          action = toggle-keyboard-shortcuts-inhibit;
        };

        # // Powers off the monitors. To turn them back on, do any input like
        # // moving the mouse or pressing any other key.
        # "Mod+Shift+P".action = power-off-monitors;

        ## Testing
        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        # "Mod+S".action = screenshot-screen;
        # # "Print".action = screenshot-screen;
        "Mod+Shift+S".action.screenshot = [ ];
        # "Shift+Print".action = screenshot;
        # "Mod+Alt+S".action = screenshot-window;
        # "Ctrl+Print".action = screenshot-window;
      }
    );
}
