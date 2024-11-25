{
  lib,
  config,
  ...
}: let
  inherit (lib) mkDefault;
  # WIP: not working
  #hyperlink_rules = attrValues (import ./hyperlink-rules.nix);
  kcfg = config.khome.desktop.terminals.wezterm;
  cfg = config.khome.programs.wezterm;
in {
  # imports = [
  #   ./style.nix
  # ];
  khome.programs.wezterm = {
    enable = true;
    settings = {
      enable_wayland = true;
      inherit (kcfg) front_end;
      #leader = { key = "a"; mods = "CTRL"; timeout_milliseconds = 10; };
      term = "wezterm";
      max_fps = 60;
      quick_select_patterns = [
        "[0-9a-f]{7,40}"
        "sha256-.{43}=" # sha256- nix hashes
      ];

      # Misc
      default_workspace = "main";
      disable_default_key_bindings = true;
      default_cwd = "~";
      exit_behavior = "CloseOnCleanExit";
      scrollback_lines = mkDefault 10000;
      set_environment_variables.TERMINFO_DIRS = "${cfg.package.passthru.terminfo}/share/terminfo/w";

      hide_tab_bar_if_only_one_tab = true;

      # Graphics
      status_update_interval = 60000; # update status bar every second
      animation_fps = 10;
      hyperlink_rules = {
        _code = true;
        str = builtins.readFile ./hyperlink-rules.lua;
      };
      keys = [
        # Appearance
        {
          key = "-";
          mods = "CTRL";
          action = "DecreaseFontSize";
        }
        {
          key = "+";
          mods = "SHIFT|CTRL";
          action = "IncreaseFontSize";
        }
        {
          key = "0";
          mods = "CTRL";
          action = "ResetFontSize";
        }

        # Search + Copy
        {
          key = "f";
          mods = "ALT|SHIFT";
          action.Search.CaseSensitiveString = "";
        }
        {
          key = "s";
          mods = "ALT|SHIFT";
          action = "QuickSelect";
        }
        {
          key = "o";
          mods = "ALT|SHIFT";
          action = {
            _code = true;
            str = ''
              act.QuickSelectArgs {
                label = 'open url',
                -- filter out quotes at end of strings if exists
                patterns = {
                  'https?://\\S+(?<!"|\'|\\`)',
                  'http?://\\S+(?<!"|\'|\\`)',
                },
                action = wezterm.action_callback(function(window, pane)
                  local url = window:get_selection_text_for_pane(pane)
                  wezterm.log_info('opening: ' .. url)
                  wezterm.open_with(url)
                end),
              }
            '';
          };
        }

        # Clipboard
        {
          key = "p";
          mods = "ALT";
          action.PasteFrom = "Clipboard";
        }
        {
          key = "p";
          mods = "ALT|SHIFT";
          action.PasteFrom = "PrimarySelection";
        }
      ];
    };
  };
}
