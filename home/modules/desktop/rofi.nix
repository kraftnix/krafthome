args:
# WARNING: this file is a mess
{
  config,
  pkgs,
  lib,
  ...
}: let
  /*
   Layout / base16 notes:
  base00 = background
  base01 = alternate highlight
  base05 = border
  base06 = select
  */
  # mkTheme = overrides: lib.recursiveUpdate
  #   {
  #     "*" = {
  #       text-color = mkLiteral foreground;
  #       background-color = mkLiteral background;
  #       accent-color = mkLiteral primary;
  #       highlight = mkLiteral secondary;
  #       margin = 0;
  #       padding = 0;
  #       spacing = 0;
  #     };
  #     window = {
  #       border = 3;
  #       padding = 5;
  #       border-color = mkLiteral "@accent-color";
  #     };
  #     listview = {
  #       fixed-height = 350;
  #       border = mkLiteral "2px 0px 0px ";
  #       padding = mkLiteral "2px 0px 0px ";
  #       text-color = mkLiteral "@accent-color";
  #     };
  #     prompt.text-color = mkLiteral "@accent-color";
  #     element = {
  #       padding = 2;
  #       spacing = 2;
  #     };
  #     element-text.text-color = mkLiteral "inherit";
  #     element-icon.size = mkLiteral "0.75em";
  #     "element normal urgent".text-color = mkLiteral "@highlight";
  #     "element normal active".text-color = mkLiteral "@highlight";
  #     "element selected".text-color = mkLiteral "@background-color";
  #     "element selected".background-color = mkLiteral "@accent-color";
  #     "element selected normal".background-color = mkLiteral "@accent-color";
  #     inputbar = {
  #       padding = mkLiteral "8px 12px";
  #       spacing = mkLiteral "12px";
  #       children = mkLiteral "[ prompt,textbox-prompt-colon,entry,num-filtered-rows,textbox-num-sep,num-rows,case-indicator ]";
  #     };
  #     num-filtered-rows = {
  #       background-color = "@highlight";
  #     };
  #     #"mode-switcher" = {
  #     #  border = "1px dash 0px 0px ";
  #     #};
  #     textbox-prompt-colon = {
  #       expand = true;
  #       str = ":";
  #       margin = mkLiteral "0px 0.3em 0em 0em ";
  #       text-color = mkLiteral "@highlight";
  #     };
  #   }
  #   overrides;
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.rofi;
in {
  options.khome.desktop.rofi = {
    enable = mkEnableOption "enable mako integration";
    enableWayland = mkEnableOption "use rofi-wayland" // {default = true;};
    theme = mkOption {
      type = with types; nullOr (oneOf [str path raw]);
      default = null;
      description = "optional theme to pass in as override, sets `programs.rofi.theme`";
      example = lib.literalExpression "./mytheme.rasi";
    };
    terminal = mkOption {
      type = types.str;
      description = "full binary path to terminal";
      default = "${pkgs.alacritty}/bin/alacritty";
    };
    plugins = mkOption {
      type = types.listOf types.package;
      description = "rofi plugins to add";
      default = with pkgs; [
        rofi-emoji
        rofi-calc
        rofi-pulse-select
        rofi-systemd
        rofi-rbw
      ];
    };
    themeOverrides = mkOption {
      default = {};
      description = "overrides passed to custom mkTheme function";
      type = types.raw;
    };
    extraConfig = mkOption {
      default = {};
      type = types.raw;
      description = "extra configuration to add to `services.mako`";
    };
  };

  config = mkIf cfg.enable {
    # home.file.".local/share/rofi/themes/base16-custom.rasi".source = config.lib.base16.getTemplate "rofi";
    # home.file.".local/share/rofi/themes/tokyonight_big1.rasi".source = ./tokyonight_big1.rasi;
    # home.file.".local/share/rofi/themes/tokyonight_big2.rasi".source = ./tokyonight_big2.rasi;
    stylix.targets.rofi.enable = true;
    programs.rofi = {
      enable = true;
      package =
        if cfg.enableWayland
        then pkgs.rofi-wayland
        else pkgs.rofi;
      inherit (cfg) plugins terminal;
      theme = mkDefault cfg.theme;
      extraConfig = mkMerge [
        {
          modi = "drun,calc,emoji,rbw,systemd,rofi-pulse,filebrowser";
          kb-accept-entry = "Return";
          kb-mode-next = "Tab,Control+l";
          kb-mode-previous = "ISO_Left_Tab,Control+h";
          # i have no idea what this fucking does but of course it suddenly breaks my old config in new rofi...
          kb-mode-complete = "";
          kb-row-up = "Up,Control+k";
          kb-row-down = "Down,Control+j";
          kb-row-tab = "";
          kb-remove-char-back = "BackSpace"; # unset, conflicting
          kb-remove-to-eol = ""; # unset, conflicting
          # upstream changed stuff again
          kb-element-next = "";
          kb-element-prev = "";
        }
        cfg.extraConfig
      ];
      # theme = "tokyonight_big2";
      # theme = "tokyonight_big2";
      # theme = mkTheme cfg.themeOverrides;
    };
  };
}
