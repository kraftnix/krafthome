{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mkAfter
    mkDefault
    mkMerge
    mkOrder
    ;
  # WIP: not working
  #hyperlink_rules = attrValues (import ./hyperlink-rules.nix);
  kcfg = config.khome.desktop.terminals.wezterm;
  cfg = config.khome.programs.wezterm;
in
{
  # imports = [
  #   ./style.nix
  #   ./copy-mode.nix
  #   ./resize-mode.nix
  # ];
  khome.programs.wezterm = {
    enable = true;
    extraPre = concatStringsSep "\n" [
      (builtins.readFile ./os-capture.lua)
      (builtins.readFile ./nvim-scrollback.lua)
      (builtins.readFile ./title.lua)
      (builtins.readFile ./right-status.lua)
      (builtins.readFile ./mux-startup.lua)
    ];
    settings = {
      enable_wayland = true;
      inherit (kcfg) front_end;
      #leader = { key = "a"; mods = "CTRL"; timeout_milliseconds = 10; };
      term = "wezterm";

      # Misic
      default_workspace = "main";
      disable_default_key_bindings = true;
      default_cwd = "~";
      exit_behavior = "CloseOnCleanExit";
      scrollback_lines = 50000;
      set_environment_variables.TERMINFO_DIRS = "${cfg.package.passthru.terminfo}/share/terminfo/w";

      # Graphics
      status_update_interval = 60000; # update status bar every second
      animation_fps = 120;
      default_gui_startup_args = [
        "connect"
        "unix"
      ];
      hyperlink_rules = {
        _code = true;
        str = builtins.readFile ./hyperlink-rules.lua;
      };

      # Multiplexing Domains
      unix_domains = mkMerge [
        (mkOrder 20 [
          { name = "unix"; }
        ])
        (mkAfter [
          {
            name = "unix-proxy";
            proxy_command = [
              "wezterm"
              "cli"
              "proxy"
            ];
          }
          {
            name = "newtest";
            local_echo_threshold_ms = 100000;
          }
        ])
        /*
          # correct way to ssh forward https://github.com/wez/wezterm/issues/1647
          {
          name = "<hostname>";
          proxy_command = [ "ssh" "-T" "-A" "<hostname>" "wezterm" "cli" "proxy" ];
          }
        */
      ];

      # Menu
      launch_menu = [
        {
          label = "Open notes in Neovim";
          args = [ "nvim" ];
          cwd = "notes";
          domain = "CurrentPaneDomain";
        }
        {
          label = "Go to repos";
          cwd = "repos";
          domain = "CurrentPaneDomain";
        }
        {
          label = "BTOP";
          args = [ "btop" ];
          domain = "CurrentPaneDomain";
        }
        {
          label = "BTM";
          args = [ "btm" ];
          domain = "CurrentPaneDomain";
        }
      ];

      # Default Keybindings
      # see all keybindings with `wezterm show-keys`
      keys = [
        # Control
        {
          key = "M";
          mods = "ALT|SHIFT";
          action.ShowLauncherArgs.flags = "FUZZY|KEY_ASSIGNMENTS";
        }
        {
          key = ";";
          mods = "ALT";
          action = "ShowTabNavigator";
        }
        {
          key = ";";
          mods = "ALT|SHIFT";
          action.ShowLauncherArgs.flags = "WORKSPACES|TABS";
        }
        {
          key = "C";
          mods = "ALT|SHIFT";
          action.ShowLauncherArgs.flags = "FUZZY|LAUNCH_MENU_ITEMS|COMMANDS";
        }
        {
          key = "_";
          mods = "ALT|SHIFT";
          action.ShowLauncherArgs.flags = "FUZZY|TABS";
        }
        {
          key = "R";
          mods = "CTRL|SHIFT";
          action = "ReloadConfiguration";
        }
        {
          key = "L";
          mods = "CTRL|SHIFT";
          action = "ShowDebugOverlay";
        }

        # Custom
        {
          key = "W";
          mods = "ALT|SHIFT";
          action.EmitEvent = "trigger-nvim-with-scrollback";
        }

        # Appearance
        {
          key = "-";
          mods = "CTRL";
          action = "DecreaseFontSize";
        }
        {
          key = "+";
          mods = "CTRL|SHIFT";
          action = "IncreaseFontSize";
        }
        {
          key = "0";
          mods = "CTRL";
          action = "ResetFontSize";
        }
        {
          key = "q";
          mods = "ALT|SHIFT|CTRL";
          action = "QuitApplication";
        }

        # Movement
        {
          key = "h";
          mods = "ALT";
          action.ActivatePaneDirection = "Left";
        }
        {
          key = "j";
          mods = "ALT";
          action.ActivatePaneDirection = "Down";
        }
        {
          key = "k";
          mods = "ALT";
          action.ActivatePaneDirection = "Up";
        }
        {
          key = "l";
          mods = "ALT";
          action.ActivatePaneDirection = "Right";
        }
        {
          key = "h";
          mods = "ALT|SHIFT";
          action.ActivateTabRelative = -1;
        }
        {
          key = "l";
          mods = "ALT|SHIFT";
          action.ActivateTabRelative = 1;
        }
        {
          key = "Tab";
          mods = "ALT";
          action = "ActivateLastTab";
        }
        {
          key = "PageUp";
          action.ScrollByPage = -1;
        }
        {
          key = "PageDown";
          action.ScrollByPage = 1;
        }
        # Scrolling to previous prompt: https://wezfurlong.org/wezterm/config/lua/keyassignment/ScrollToPrompt.html
        {
          key = "u";
          mods = "CTRL|ALT";
          action = {
            _code = true;
            str = "act.ScrollToPrompt(-1)";
          };
        }
        {
          key = "d";
          mods = "CTRL|ALT";
          action = {
            _code = true;
            str = "act.ScrollToPrompt(1)";
          };
        }

        # Window mgmt
        {
          key = "n";
          mods = "ALT|SHIFT";
          action = "SpawnWindow";
        }
        {
          key = "t";
          mods = "ALT";
          action.SpawnTab = "CurrentPaneDomain";
        }
        {
          key = "t";
          mods = "ALT|SHIFT";
          action.SpawnCommandInNewTab.cwd = "";
        }
        {
          key = "x";
          mods = "ALT";
          action.SplitVertical.domain = "CurrentPaneDomain";
        }
        {
          key = "v";
          mods = "ALT";
          action.SplitHorizontal.domain = "CurrentPaneDomain";
        }
        {
          key = "q";
          mods = "ALT|SHIFT";
          action.CloseCurrentPane.confirm = true;
        }
        {
          key = "{";
          mods = "ALT|SHIFT";
          action = {
            _code = true;
            str = "wezterm.action{MoveTabRelative=-1}";
          };
        }
        {
          key = "}";
          mods = "ALT|SHIFT";
          action = {
            _code = true;
            str = "wezterm.action{MoveTabRelative=1}";
          };
        }
        {
          key = "z";
          mods = "ALT";
          action = "TogglePaneZoomState";
        }
        {
          key = "-";
          mods = "ALT";
          action = {
            _code = true;
            str = "wezterm.action{ShowLauncherArgs={flags=\"FUZZY|WORKSPACES\"}}";
          };
        }
        {
          key = "b";
          mods = "ALT|SHIFT";
          action.RotatePanes = "CounterClockwise";
        }

        # Scroll
        #{ key = "u"; mods = "ALT|SHIFT"; action = { ScrollByPage = -1; }; }
        #{ key = "d"; mods = "ALT|SHIFT"; action = { ScrollByPage = 1; }; }
        {
          # Copy and leave Copy Mode
          key = "u";
          mods = "ALT|SHIFT";
          action = {
            _code = true;
            str = ''
              act.Multiple {
                act.ActivateCopyMode,
                { CopyMode = 'PageUp' },
              }
            '';
          };
        }
        {
          # Copy and leave Copy Mode
          key = "d";
          mods = "ALT|SHIFT";
          action = {
            _code = true;
            str = ''
              act.Multiple {
                act.ActivateCopyMode,
                { CopyMode = 'PageDown' },
              }
            '';
          };
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
        {
          key = "a";
          mods = "ALT|SHIFT";
          action = "ActivateCopyMode";
        }
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
      #++
      # NOTE(disabled): now use ALT+M or ALT+hjkl to move
      # map all tab numbers to ALT instead of SUPER
      #(map
      #  (key:
      #    let tab = key - 1; in
      #    { key = toString key; mods = "ALT"; action.ActivateTab = tab; }
      #  ) [ 1 2 3 4 5 6 7 8 9 ]);
    };
  };
}
