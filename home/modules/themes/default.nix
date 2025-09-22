localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;
  opts = localFlake.inputs.provision.lib.options;
  cfg = config.khome.themes;
  colours = config.lib.stylix.colors.withHashtag;
in
{
  imports = [ ./base16-nix ];
  options.khome.themes = {
    enable = mkEnableOption "enable themes integration";
    hosts = {
      currHostname = mkOption {
        default = "";
        description = "set current hostname";
        type = types.str;
      };
      defaultColour = mkOption {
        default = "";
        description = "default host colour";
        type = types.str;
      };
      colours = mkOption {
        default = { };
        description = "set of (host -> colour), assign a unique colour per host";
        type = with types; attrsOf str;
      };
      currHostColour = mkOption {
        default = "";
        description = "default host colour";
        type = types.str;
      };
    };
    polarity = mkOption {
      type =
        with types;
        enum [
          "either"
          "dark"
          "light"
        ];
      default = "dark";
      description = "dark or light theming";
    };
    opacity = mkOption {
      type = types.float;
      default = 1.0;
      description = "default opacity";
    };
    override = mkOption {
      type = types.attrs;
      default = { };
      description = "default override";
    };
    stylix = {
      enable = opts.enable' cfg.enable "enable stylix";
      includeOverlays = opts.enable "add stylix overlays to home-manager";
      base16 = {
        name = opts.string "tokyo-night-storm" "name of base16 scheme";
        scheme = mkOption {
          description = "base16 scheme to use, inferred from name";
          type =
            with types;
            oneOf [
              path
              lines
              attrs
            ];
          default = "${pkgs.base16-schemes}/share/themes/${cfg.stylix.base16.name}.yaml";
        };
      };
      extra = mkOption {
        type = types.raw;
        default = { };
        description = "extra options to add to `stylix`";
      };
    };
    gtk = {
      enable = mkEnableOption "GTK Theming";
      theme = mkOption {
        type = with types; nullOr package;
        default = null;
        description = "gtk theme";
      };
      icon = mkOption {
        type = with types; nullOr package;
        default = null;
        description = "gtk icon theme";
      };
    };
    qt = {
      enable = mkEnableOption "QT Theming";
      name = opts.string "breeze-dark" "qt theme name";
      platformTheme = opts.string "gtk" "gtk platform theme type";
    };
    images = {
      wallpaper = mkOption {
        default = localFlake.self.packages.${pkgs.system}.stylix-default-wallpaper;
        description = "path to default wallpaper";
        type = with types; package;
      };
      screensaver = mkOption {
        default = cfg.images.wallpaper;
        description = "path screensaver image";
        type =
          with types;
          oneOf [
            pathInStore
            str
          ];
      };
      wallpaperDir = opts.string "/home/$user/Pictures/Wallpapers" "path to wallpapers directory";
    };
  };

  config = mkIf cfg.enable {
    khome.themes.hosts.defaultColour = colours.cyan;
    khome.themes.hosts.currHostColour =
      if builtins.hasAttr cfg.hosts.currHostname cfg.hosts.colours then
        cfg.hosts.colours.${cfg.hosts.currHostname}
      else
        cfg.hosts.defaultColour;
    stylix = {
      enable = cfg.stylix.enable;
      overlays.enable = cfg.stylix.includeOverlays;
      image = cfg.images.wallpaper;
      polarity = cfg.polarity;
      base16Scheme = cfg.stylix.base16.scheme;
      targets.wezterm.enable = false;
      targets.gtk.enable = cfg.gtk.enable;
      targets.qt.platform = lib.mkOverride 900 "qtct"; # can't use mkDefault for some reason
      opacity = {
        terminal = mkDefault cfg.opacity;
        applications = mkDefault cfg.opacity;
        popups = mkDefault cfg.opacity;
        desktop = mkDefault cfg.opacity;
      };
      override = mkDefault cfg.override;
    }
    // cfg.stylix.extra;

    gtk.theme.package = mkIf (cfg.gtk.theme != null) cfg.gtk.theme;
    gtk.theme.name = mkIf (cfg.gtk.theme != null) cfg.gtk.theme.name;

    home.sessionVariables =
      { }
      // mkIf (cfg.gtk.enable && cfg.gtk.theme != null) {
        GTK_THEME = cfg.gtk.theme.name;
      }
      // mkIf cfg.qt.enable {
        QT_QPA_PLATFORM = "wayland";
        # QT_PLATFORMTHEME = cfg.qt.name;
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };

    # # QT theming
    # qt = mkIf ((!cfg.stylix.enable) && cfg.qt.enable) {
    #   inherit (cfg.qt) enable;
    #   platformTheme = mkIf (cfg.qt.platformTheme != null) cfg.qt.platformTheme;
    # };

    lib.gSettings = mkIf cfg.gtk.enable ''
      set $gnome-schema org.gnome.desktop.interface

      exec_always {
          ${optionalString (
            cfg.gtk.theme != null
          ) "gsettings set $gnome-schema gtk-theme '${cfg.gtk.theme.name}'"}
          ${optionalString (
            cfg.gtk.icon != null
          ) "gsettings set $gnome-schema icon-theme '${cfg.gtk.icon.name}'"}
          #gsettings set $gnome-schema cursor-theme 'Your cursor Theme'
          gsettings set $gnome-schema font-name '${config.stylix.fonts.monospace.name}'
      }
    '';
  };
}
