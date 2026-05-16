{
  lib,
  config,
  pkgs,
  ...
}:
let
  niriNull = _: { };
in
{
  khome.desktop.wm.niri.settings.recent-windows = {
    debounce-ms = 750;
    open-delay-ms = 150;
    binds = {
      "Mod+Tab".next-window = niriNull;
      "Mod+Shift+Tab".previous-window = niriNull;
      "Mod+grave".next-window = _: { props.filter = "app-id"; };
      "Mod+Shift+grave".previous-window = _: { props.filter = "app-id"; };
    };
  };
  khome.desktop.wm.niri.settings.binds = {
    "Mod+Shift+Slash" = _: {
      content.show-hotkey-overlay = niriNull;
      props.hotkey-overlay-title = "Show hotkey overlay";
    };

    "Mod+Alt+L" = _: {
      content.spawn = "swaylock";
      props.hotkey-overlay-title = "Lock the Screen: swaylock";
    };

    "Mod+X" = _: {
      props.repeat = false;
      props.hotkey-overlay-title = "Toggle Overview";
      content.toggle-overview = niriNull;
    };

    "Mod+Shift+Q" = _: {
      content.close-window = niriNull;
      props.repeat = false;
      props.hotkey-overlay-title = "Close window";
    };

    "XF86AudioRaiseVolume".spawn = [
      "wpctl"
      "set-volume"
      "@DEFAULT_AUDIO_SINK@"
      "0.1+"
    ];
    "XF86AudioLowerVolume".spawn = [
      "wpctl"
      "set-volume"
      "@DEFAULT_AUDIO_SINK@"
      "0.1-"
    ];

    "Mod+1".focus-workspace = 1;
    "Mod+2".focus-workspace = 2;
    "Mod+3".focus-workspace = 3;
    "Mod+4".focus-workspace = 4;
    "Mod+5".focus-workspace = 5;
    "Mod+6".focus-workspace = 6;
    "Mod+7".focus-workspace = 7;
    "Mod+8".focus-workspace = 8;
    "Mod+9".focus-workspace = 9;

    "Mod+Shift+1".move-window-to-workspace = 1;
    "Mod+Shift+2".move-window-to-workspace = 2;
    "Mod+Shift+3".move-window-to-workspace = 3;
    "Mod+Shift+4".move-window-to-workspace = 4;
    "Mod+Shift+5".move-window-to-workspace = 5;
    "Mod+Shift+6".move-window-to-workspace = 6;
    "Mod+Shift+7".move-window-to-workspace = 7;
    "Mod+Shift+8".move-window-to-workspace = 8;
    "Mod+Shift+9".move-window-to-workspace = 9;

    "Mod+Shift+E" = _: {
      content.quit = niriNull;
      props.hotkey-overlay-title = "Quit";
    };
    "Mod+Ctrl+Shift+E" = _: {
      content.quit = _: { props.skip-confirmation = true; };
      props.hotkey-overlay-title = "Force Quit";
    };

    "Mod+f".fullscreen-window = niriNull;

    "Mod+Left".focus-column-left = niriNull;
    "Mod+Down".focus-window-down = niriNull;
    "Mod+Up".focus-window-up = niriNull;
    "Mod+Right".focus-column-right = niriNull;
    "Mod+H".focus-column-left = niriNull;
    "Mod+J".focus-window-or-workspace-down = niriNull;
    "Mod+K".focus-window-or-workspace-up = niriNull;
    "Mod+L".focus-column-right = niriNull;

    "Mod+Ctrl+Left".move-column-left = niriNull;
    "Mod+Ctrl+Down".move-window-down = niriNull;
    "Mod+Ctrl+Up".move-window-up = niriNull;
    "Mod+Ctrl+Right".move-column-right = niriNull;
    "Mod+Ctrl+H".move-column-left = niriNull;
    "Mod+Ctrl+J".move-window-down-or-to-workspace-down = niriNull;
    # "Mod+Ctrl+J".move-window-down = niriNull;
    # "Mod+Ctrl+K".move-window-up = niriNull;
    "Mod+Ctrl+K".move-window-up-or-to-workspace-up = niriNull;
    "Mod+Ctrl+L".move-column-right = niriNull;

    "Mod+Home".focus-column-first = niriNull;
    "Mod+End".focus-column-last = niriNull;
    "Mod+Ctrl+Home".move-column-to-first = niriNull;
    "Mod+Ctrl+End".move-column-to-last = niriNull;

    "Mod+Shift+Left".focus-monitor-left = niriNull;
    "Mod+Shift+Down".focus-monitor-down = niriNull;
    "Mod+Shift+Up".focus-monitor-up = niriNull;
    "Mod+Shift+Right".focus-monitor-right = niriNull;
    "Mod+Shift+H".focus-monitor-left = niriNull;
    "Mod+Shift+J".focus-monitor-down = niriNull;
    "Mod+Shift+K".focus-monitor-up = niriNull;
    "Mod+Shift+L".focus-monitor-right = niriNull;

    "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = niriNull;
    "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = niriNull;
    "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = niriNull;
    "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = niriNull;
    "Mod+Shift+Ctrl+H".move-column-to-monitor-left = niriNull;
    "Mod+Shift+Ctrl+J".move-column-to-monitor-down = niriNull;
    "Mod+Shift+Ctrl+K".move-column-to-monitor-up = niriNull;
    "Mod+Shift+Ctrl+L".move-column-to-monitor-right = niriNull;

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
    "Mod+WheelScrollDown" = _: {
      props.cooldown-ms = 150;
      content.focus-workspace-down = niriNull;
    };
    "Mod+WheelScrollUp" = _: {
      props.cooldown-ms = 150;
      content.focus-workspace-up = niriNull;
    };
    "Mod+Ctrl+WheelScrollDown" = _: {
      props.cooldown-ms = 150;
      content.move-column-to-workspace-down = niriNull;
    };
    "Mod+Ctrl+WheelScrollUp" = _: {
      props.cooldown-ms = 150;
      content.move-column-to-workspace-up = niriNull;
    };
    # Mod+WheelScrollRight      { focus-column-right; }
    # Mod+WheelScrollLeft       { focus-column-left; }
    # Mod+Ctrl+WheelScrollRight { move-column-right; }
    # Mod+Ctrl+WheelScrollLeft  { move-column-left; }

    # // Usually scrolling up and down with Shift in applications results in
    # // horizontal scrolling; these binds replicate that.
    "Mod+Shift+WheelScrollDown".focus-column-right = niriNull;
    "Mod+Shift+WheelScrollUp".focus-column-left = niriNull;
    "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = niriNull;
    "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = niriNull;

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
    "Mod+Tab".focus-workspace-previous = niriNull;
    "Mod+Shift+Tab".focus-window-previous = niriNull;

    # // The following binds move the focused window in and out of a column.
    # // If the window is alone, they will consume it into the nearby column to the side.
    # // If the window is already in a column, they will expel it out.
    "Mod+BracketLeft".consume-or-expel-window-left = niriNull;
    "Mod+BracketRight".consume-or-expel-window-right = niriNull;

    # // Consume one window from the right to the bottom of the focused column.
    "Mod+Comma".consume-window-into-column = niriNull;
    # // Expel the bottom window from the focused column to the right.
    "Mod+Period".expel-window-from-column = niriNull;

    "Mod+R" = _: {
      content.switch-preset-column-width = niriNull;
      props.hotkey-overlay-title = "Toggle preset column widths";
    };

    "Mod+o" = _: {
      content.toggle-window-rule-opacity = niriNull;
      props.hotkey-overlay-title = "Toggle opacity on current window";
    };
    # // Cycling through the presets in reverse order is also possible.
    # // Mod+R { switch-preset-column-width-back; }
    # Mod+Shift+R { switch-preset-window-height; }
    # Mod+Ctrl+R { reset-window-height; }
    # swapped from default
    "Mod+Shift+F" = _: {
      content.maximize-column = niriNull;
      props.hotkey-overlay-title = "Maximize current column";
    };

    "Mod+Shift+W" = {
      spawn = [
        "${lib.getExe pkgs.wl-kbptr}"
        "-o"
        "modes=floating,click"
        "-o"
        "mode_floating.source=detect"
      ];
    };

    # // Expand the focused column to space not taken up by other fully visible columns.
    # // Makes the column "fill the rest of the space".
    "Mod+Ctrl+F" = _: {
      content.expand-column-to-available-width = niriNull;
      props.hotkey-overlay-title = "Expand current column to available width";
    };
    "Mod+C" = _: {
      content.center-column = niriNull;
      props.hotkey-overlay-title = "Center current window";
    };

    # // Center all fully visible columns on screen.
    "Mod+Ctrl+C".center-visible-columns = niriNull;

    # // Finer width adjustments.
    # // This command can also:
    # // * set width in pixels: "1000"
    # // * adjust width in pixels: "-5" or "+5"
    # // * set width as a percentage of screen width: "25%"
    # // * adjust width as a percentage of screen width: "-10%" or "+10%"
    # // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
    # // set-column-width "100" will make the column occupy 200 physical screen pixels.
    "Mod+Minus".set-column-width = "-10%";
    "Mod+Equal".set-column-width = "+10%";
    "Mod+Plus".set-column-width = "+10%";

    # // Finer height adjustments when in column with other windows.
    "Mod+Shift+Minus".set-window-height = "-10%";
    "Mod+Shift+Equal".set-window-height = "+10%";

    # // Move the focused window between the floating and the tiling layout.
    "Mod+Space".switch-focus-between-floating-and-tiling = niriNull;
    "Mod+Shift+Space".toggle-window-floating = niriNull;

    # // Toggle tabbed column display mode.
    # // Windows in this column will appear as vertical tabs,
    # // rather than stacked on top of each other.
    "Mod+W".toggle-column-tabbed-display = niriNull;

    # // Actions to switch layouts.
    # // Note: if you uncomment these, make sure you do NOT have
    # // a matching layout switch hotkey configured in xkb options above.
    # // Having both at once on the same hotkey will break the switching,
    # // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
    # // Mod+Space       { switch-layout "next"; }
    # // Mod+Shift+Space { switch-layout "prev"; }
    "Print".screenshot = niriNull;
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
    "Mod+Escape" = _: {
      props.allow-inhibiting = false;
      content.toggle-keyboard-shortcuts-inhibit = niriNull;
    };

    # // Powers off the monitors. To turn them back on, do any input like
    # // moving the mouse or pressing any other key.
    # "Mod+Shift+P".action = power-off-monitors;

    ## Testing
    "Mod+V".toggle-window-floating = niriNull;
    "Mod+Shift+V".switch-focus-between-floating-and-tiling = niriNull;

    # "Mod+S".action = screenshot-screen;
    # # "Print".action = screenshot-screen;
    "Mod+Shift+S".screenshot = niriNull;
    # "Shift+Print".action = screenshot;
    # "Mod+Alt+S".action = screenshot-window;
    # "Ctrl+Print".action = screenshot-window;
  };

}
