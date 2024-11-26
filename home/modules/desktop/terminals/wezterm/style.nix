{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    mapAttrsToList
    mkBefore
    ;
  # NOTE: improve this handling with base16 refactoring
  colors = config.lib.stylix.colors.withHashtag;
  baseColors =
    if config.khome.themes.enable then
      (with colors; {
        background = base00;
        backgroundAlt = base01;
        foreground = base05;
        primary = base0D;
        secondary = base0C;
        blue = base0E;
        green = base0B;
        orange = base09;
        base02 = base02;
      })
    else
      rec {
        background = "#0b0022";
        backgroundAlt = "#0b3322";
        foreground = "#c0c0c0";
        primary = "#2b2042";
        secondary = "#c0c0c0";
        blue = "#7aa2f7";
        green = "#9ece6a";
        orange = "#ff9e64";
        base02 = green;
      };
  colorVars = concatStringsSep "\n" (
    mapAttrsToList (name: val: ''local ${name} = "${val}";'') (
      filterAttrs (n: _: !(lib.hasInfix "-" n)) baseColors
    )
  );
in
{
  khome.programs.wezterm = {
    extraPre = mkBefore colorVars;
    settings = {
      #use_fancy_tab_bar = false;
      window_background_opacity = config.stylix.opacity.terminal;
      # font = {
      #   _code = true;
      #   # str = "wezterm.font(\"${config.stylix.font.family}\")";
      #   str = ''
      #     wezterm.font_with_fallback {
      #         \"${config.stylix.fonts.monospace.name}\",
      #         \"${config.stylix.fonts.emoji.name}\",
      #     }
      #   '';
      #
      # };
      warn_about_missing_glyphs = false;
      color_scheme = "Tinacious Design (Dark)";
      tab_bar_at_bottom = true;
      switch_to_last_active_tab_when_closing_tab = true;
      window_frame = {
        active_titlebar_bg = baseColors.backgroundAlt;
        inactive_titlebar_bg = baseColors.background;
      };
      colors = {
        tab_bar = {
          background = baseColors.green;
          inactive_tab_edge = baseColors.blue;
          # doesn't seem to do much
          inactive_tab = {
            fg_color = baseColors.orange;
            bg_color = baseColors.backgroundAlt;
          };
          new_tab = {
            fg_color = baseColors.primary;
            bg_color = baseColors.base02;
          };
        };
      };
      window_padding = {
        left = 0;
        right = 0;
        top = 0;
        bottom = 0;
      };
    };
  };
}
