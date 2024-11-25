{
  khome.programs.wezterm.settings = {
    keys = [
      {
        key = "r";
        mods = "LEADER";
        action = {
          _code = true;
          str = ''
            act.ActivateKeyTable {
              name = 'resize_mode',
              one_shot = false,
              replace_current = false,
            }
          '';
        };
      }
    ];
    key_tables.resize_mode = [
      {
        key = "LeftArrow";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Left', 1 }";
        };
      }
      {
        key = "h";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Left', 1 }";
        };
      }
      {
        key = "h";
        mods = "CTRL";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Left', 3 }";
        };
      }

      {
        key = "RightArrow";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Right', 1 }";
        };
      }
      {
        key = "l";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Right', 1 }";
        };
      }
      {
        key = "l";
        mods = "CTRL";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Right', 3 }";
        };
      }

      {
        key = "UpArrow";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Up', 1 }";
        };
      }
      {
        key = "k";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Up', 1 }";
        };
      }
      {
        key = "k";
        mods = "CTRL";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Up', 3 }";
        };
      }

      {
        key = "DownArrow";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Down', 1 }";
        };
      }
      {
        key = "j";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Down', 1 }";
        };
      }
      {
        key = "j";
        mods = "CTRL";
        action = {
          _code = true;
          str = "act.AdjustPaneSize { 'Down', 3 }";
        };
      }

      # Cancel the mode by pressing escape
      {
        key = "Escape";
        action = "PopKeyTable";
      }
    ];
  };
}
