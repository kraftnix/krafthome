{
  lib,
  config,
  pkgs,
  ...
}:
let
  shared = [
    {
      key = "j";
      mods = "CTRL";
      action = {
        CopyMode = "NextMatch";
      };
    }
    {
      key = "J";
      mods = "CTRL";
      action = {
        CopyMode = "NextMatchPage";
      };
    }
    {
      key = "k";
      mods = "CTRL";
      action = {
        CopyMode = "PriorMatch";
      };
    }
    {
      key = "K";
      mods = "CTRL|SHIFT";
      action = {
        CopyMode = "PriorMatchPage";
      };
    }
    {
      key = "l";
      mods = "CTRL";
      action = {
        CopyMode = "ClearPattern";
      };
    }
    {
      # Copy without leaving Copy Mode
      key = "l";
      mods = "ALT|SHIFT";
      action = {
        _code = true;
        str = ''
          act.Multiple {
            act.ClearSelection,
            -- clear the selection mode, but remain in copy mode
            { CopyMode = 'ClearSelectionMode' },
          }
        '';
      };
    }
  ];
in
{
  khome.programs.wezterm.settings = {
    key_tables.search_mode = [
      {
        key = "Escape";
        mods = "NONE";
        action = {
          CopyMode = "Close";
        };
      }
      {
        key = "Enter";
        mods = "SHIFT";
        action = {
          CopyMode = "AcceptPattern";
        };
      }
      {
        key = "Enter";
        mods = "NONE";
        action = "ActivateCopyMode";
      }
      {
        key = "r";
        mods = "CTRL";
        action = {
          CopyMode = "CycleMatchType";
        };
      }
      {
        key = "e";
        mods = "CTRL";
        action = {
          CopyMode = "EditPattern";
        };
      }
    ]
    ++ shared;
    key_tables.copy_mode = shared ++ [
      {
        # Copy without leaving Copy Mode
        key = "y";
        mods = "NONE";
        action = {
          _code = true;
          str = ''
            act.Multiple {
              { CopyTo = 'ClipboardAndPrimarySelection' },
              act.ClearSelection,
              -- clear the selection mode, but remain in copy mode
              { CopyMode = 'ClearSelectionMode' },
            }
          '';
        };
      }
      {
        # Copy and leave Copy Mode
        key = "y";
        mods = "ALT|SHIFT";
        action = {
          _code = true;
          str = ''
            act.Multiple {
              { CopyTo = 'ClipboardAndPrimarySelection' },
              { CopyMode = 'Close' },
            }
          '';
        };
      }
      {
        key = "u";
        mods = "CTRL";
        action = {
          CopyMode = "PageUp";
        };
      }
      {
        key = "d";
        mods = "CTRL";
        action = {
          CopyMode = "PageDown";
        };
      }

      # Integrate with search mode
      {
        key = "Escape";
        mods = "CTRL";
        action = {
          _code = true;
          str = ''
            act.Multiple {
              act.ClearSelection,
              -- clear the selection mode, but remain in copy mode
              { CopyMode = 'ClearSelectionMode' },
            }
          '';
        };
      }

      # extra movement
      {
        key = "Tab";
        mods = "NONE";
        action = {
          CopyMode = "MoveForwardSemanticZone";
        };
      }
      {
        key = "Tab";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveBackwardSemanticZone";
        };
      }

      # Below are all defaults
      #{ key = "Tab"; mods = "NONE"; action = { CopyMode = "MoveForwardWord"; }; }
      #{ key = "Tab"; mods = "SHIFT"; action = { CopyMode = "MoveBackwardWord"; }; }
      {
        key = "Enter";
        mods = "NONE";
        action = {
          CopyMode = "MoveToStartOfNextLine";
        };
      }
      {
        key = "Escape";
        mods = "NONE";
        action = {
          CopyMode = "Close";
        };
      }
      {
        key = "Space";
        mods = "NONE";
        action = {
          _code = true;
          str = "act.CopyMode { SetSelectionMode = 'Cell' }";
        };
      }
      {
        key = "$";
        mods = "NONE";
        action = {
          CopyMode = "MoveToEndOfLineContent";
        };
      }
      {
        key = "$";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToEndOfLineContent";
        };
      }
      {
        key = "0";
        mods = "NONE";
        action = {
          CopyMode = "MoveToStartOfLine";
        };
      }
      {
        key = "G";
        mods = "NONE";
        action = {
          CopyMode = "MoveToScrollbackBottom";
        };
      }
      {
        key = "G";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToScrollbackBottom";
        };
      }
      {
        key = "H";
        mods = "NONE";
        action = {
          CopyMode = "MoveToViewportTop";
        };
      }
      {
        key = "H";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToViewportTop";
        };
      }
      {
        key = "L";
        mods = "NONE";
        action = {
          CopyMode = "MoveToViewportBottom";
        };
      }
      {
        key = "L";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToViewportBottom";
        };
      }
      {
        key = "M";
        mods = "NONE";
        action = {
          CopyMode = "MoveToViewportMiddle";
        };
      }
      {
        key = "M";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToViewportMiddle";
        };
      }
      {
        key = "O";
        mods = "NONE";
        action = {
          CopyMode = "MoveToSelectionOtherEndHoriz";
        };
      }
      {
        key = "O";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToSelectionOtherEndHoriz";
        };
      }
      {
        key = "V";
        mods = "NONE";
        action = {
          _code = true;
          str = "act.CopyMode { SetSelectionMode = 'Line' }";
        };
      }
      {
        key = "V";
        mods = "SHIFT";
        action = {
          _code = true;
          str = "act.CopyMode { SetSelectionMode = 'Line' }";
        };
      }
      {
        key = "^";
        mods = "NONE";
        action = {
          CopyMode = "MoveToStartOfLineContent";
        };
      }
      {
        key = "^";
        mods = "SHIFT";
        action = {
          CopyMode = "MoveToStartOfLineContent";
        };
      }
      {
        key = "b";
        mods = "NONE";
        action = {
          CopyMode = "MoveBackwardWord";
        };
      }
      {
        key = "b";
        mods = "ALT";
        action = {
          CopyMode = "MoveBackwardWord";
        };
      }
      {
        key = "b";
        mods = "CTRL";
        action = {
          CopyMode = "PageUp";
        };
      }
      {
        key = "c";
        mods = "CTRL";
        action = {
          CopyMode = "Close";
        };
      }
      {
        key = "f";
        mods = "ALT";
        action = {
          CopyMode = "MoveForwardWord";
        };
      }
      {
        key = "f";
        mods = "CTRL";
        action = {
          CopyMode = "PageDown";
        };
      }
      {
        key = "g";
        mods = "NONE";
        action = {
          CopyMode = "MoveToScrollbackTop";
        };
      }
      {
        key = "g";
        mods = "CTRL";
        action = {
          CopyMode = "Close";
        };
      }
      {
        key = "h";
        mods = "NONE";
        action = {
          CopyMode = "MoveLeft";
        };
      }
      {
        key = "j";
        mods = "NONE";
        action = {
          CopyMode = "MoveDown";
        };
      }
      {
        key = "k";
        mods = "NONE";
        action = {
          CopyMode = "MoveUp";
        };
      }
      {
        key = "l";
        mods = "NONE";
        action = {
          CopyMode = "MoveRight";
        };
      }
      {
        key = "m";
        mods = "ALT";
        action = {
          CopyMode = "MoveToStartOfLineContent";
        };
      }
      {
        key = "o";
        mods = "NONE";
        action = {
          CopyMode = "MoveToSelectionOtherEnd";
        };
      }
      {
        key = "q";
        mods = "NONE";
        action = {
          CopyMode = "Close";
        };
      }
      {
        key = "v";
        mods = "NONE";
        action = {
          _code = true;
          str = "act.CopyMode { SetSelectionMode = 'Cell' }";
        };
      }
      {
        key = "v";
        mods = "CTRL";
        action = {
          _code = true;
          str = "act.CopyMode { SetSelectionMode = 'Block' }";
        };
      }
      {
        key = "w";
        mods = "NONE";
        action = {
          CopyMode = "MoveForwardWord";
        };
      }
      #{ key = " "; mods = "NONE"; action = { CopyMode = "ToggleSelectionByCell"; }; }
      #{
      #  key = "y";
      #  mods = "NONE";
      #  action = {
      #    _code = true;
      #    str = ''
      #      act.Multiple {
      #        { CopyTo = 'ClipboardAndPrimarySelection' },
      #        { CopyMode = 'Close' },
      #      }
      #    '';
      #  };
      #}
      {
        key = "PageUp";
        mods = "NONE";
        action = {
          CopyMode = "PageUp";
        };
      }
      {
        key = "PageDown";
        mods = "NONE";
        action = {
          CopyMode = "PageDown";
        };
      }
      {
        key = "LeftArrow";
        mods = "NONE";
        action = {
          CopyMode = "MoveLeft";
        };
      }
      {
        key = "LeftArrow";
        mods = "ALT";
        action = {
          CopyMode = "MoveBackwardWord";
        };
      }
      {
        key = "RightArrow";
        mods = "NONE";
        action = {
          CopyMode = "MoveRight";
        };
      }
      {
        key = "RightArrow";
        mods = "ALT";
        action = {
          CopyMode = "MoveForwardWord";
        };
      }
      {
        key = "UpArrow";
        mods = "NONE";
        action = {
          CopyMode = "MoveUp";
        };
      }
      {
        key = "DownArrow";
        mods = "NONE";
        action = {
          CopyMode = "MoveDown";
        };
      }
    ];
  };
}
