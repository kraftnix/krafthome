{
  config,
  pkgs,
  lib,
  ...
}:
let
  gaps = {
    inner = 14;
    outer = -2;
    smartGaps = true;
    smartBorders = "on";
  };
  # base16 theme
  extraConfig = ''
    ## Gaps mode - edit size of gaps in realtime
    # Press $mod+Shift+g to enter the gap mode.
    # Choose o or i for modifying outer/inner gaps.
    # Press one of + / - (in-/decrement for current workspace) or 0 (remove gaps for current workspace).
    # If you also press Shift with these keys, the change will be global for all workspaces.
    set $mode_gaps Gaps: (o) outer, (i) inner
    set $mode_gaps_outer Outer Gaps: +|-|0 (local), Shift + +|-|0 (global)
    set $mode_gaps_inner Inner Gaps: +|-|0 (local), Shift + +|-|0 (global)
    bindsym $mod+Shift+g mode "$mode_gaps"

    mode "$mode_gaps" {
        bindsym o      mode "$mode_gaps_outer"
        bindsym i      mode "$mode_gaps_inner"
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    mode "$mode_gaps_inner" {
        bindsym plus  gaps inner current plus 5
        bindsym minus gaps inner current minus 5
        bindsym 0     gaps inner current set 0

        bindsym Shift+plus  gaps inner all plus 5
        bindsym Shift+minus gaps inner all minus 5
        bindsym Shift+0     gaps inner all set 0

        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    mode "$mode_gaps_outer" {
        bindsym plus  gaps outer current plus 5
        bindsym minus gaps outer current minus 5
        bindsym 0     gaps outer current set 0

        bindsym Shift+plus  gaps outer all plus 5
        bindsym Shift+minus gaps outer all minus 5
        bindsym Shift+0     gaps outer all set 0

        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
  '';
in
{
  wayland.windowManager.sway = {
    inherit extraConfig;
    config = {
      inherit gaps;
    };
  };
  xsession.windowManager.i3 = {
    inherit extraConfig;
    package = pkgs.i3-gaps;
    config = {
      inherit gaps;
    };
  };
}
