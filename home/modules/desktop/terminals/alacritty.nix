{self, ...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional optionals;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.desktop.terminals.alacritty;
in {
  options.khome.desktop.terminals.alacritty = {
    enable = opts.enable "enable alacritty";
  };

  config = mkIf cfg.enable {
    stylix.targets.alacritty.enable = config.khome.themes.stylix.enable;
    programs.alacritty = {
      enable = true;
      settings = {
        scrolling = {
          history = 0;
          multiplier = 3;
        };
        font = {
          offset = {
            x = 0;
            y = 0;
          };
        };
        keyboard.bindings = [
          # tofix
          #{
          #  key = "Home";
          #  chars = "\x1b0H";
          #  mode = "AppCursor";
          #}
          #{
          #  key = "Home";
          #  chars = "\x1b[H";
          #  mode = "~AppCursor";
          #}
          #{
          #  key = "End";
          #  chars = "\x1bOF";
          #  mode = "AppCursor";
          #}
          #{
          #  key = "End";
          #  chars = "\x1b[F";
          #  mode = "~AppCursor";
          #}
          #{
          #  key = "Delete";
          #  chars = "\x1b[3~";
          #}
          #{
          #  key = "E";
          #  chars = "\x01\"";
          #}  # split
          #{
          #  key = "Tab";
          #  chars = "\x01n";
          #}  # select next tab
          #{
          #  key = "Tab";
          #  chars = "\x01p";
          #}  # select previous tab
          {
            key = "L";
            chars = "\\\\x01n";
            mods = "Control";
          } # select next tab
          {
            key = "H";
            chars = "\\\\x01p";
            mods = "Control";
          } # select previous tab
          #{
          #  key = "Z";
          #  chars = "\x01z";
          #}  # zoom pane
        ];
      };
    };
  };
}
