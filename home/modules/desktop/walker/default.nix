localFlake:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    flatten
    mapAttrs
    mapAttrsToList
    mkDefault
    mkIf
    mkMerge
    mkOption
    typeOf
    types
    ;
  cfg = config.programs.walker;
  toml = pkgs.formats.toml { };
  custom = cfg.themes.custom;
in
{
  options.programs.walker = {
    enable = mkOption {
      description = "Whether to enable walker completion.";
      default = false;
      type = types.bool;
    };

    key = mkOption {
      description = "hyprland mod key (with $mod)";
      default = "d";
      type = types.str;
    };

    walkerExec = mkOption {
      description = "exec command run by sway/hyprland";
      default = "env GSK_RENDERER=ngl walker";
      type = types.str;
    };

    settings = mkOption {
      description = "settings for walker";
      default = { };
      type = toml.type;
    };

    themes = mkOption {
      description = "themes to add to $XDG_CONFIG_HOME/walker/themes";
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            width = mkOption {
              description = "width of ui, used in custom theme";
              default = 600;
              type = types.int;
            };
            height = mkOption {
              description = "height of ui, used in custom theme";
              default = 440;
              type = types.int;
            };
            layout = mkOption {
              description = "layout file";
              default = { };
              type = types.oneOf [
                toml.type
                types.pathInStore
              ];
            };
            style = mkOption {
              description = "css file";
              default = ./custom.css;
              type = types.pathInStore;
            };
          };
        }
      );
    };

    runAsService = mkOption {
      description = "Run walker as a service for faster startup times.";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = mkMerge (flatten [
      { "walker/config.toml".source = toml.generate "walker-config.toml" cfg.settings; }
      (mapAttrsToList (theme: source: {
        "walker/themes/${theme}.toml".source =
          if typeOf source.layout == "path" then
            source.layout
          else
            toml.generate "walker-theme-${theme}.toml" source.layout;
        "walker/themes/${theme}.css".source = source.style;
      }) cfg.themes)
    ]);
    home.packages = with pkgs; [
      walker
      libqalculate
    ];

    systemd.user.services.walker = mkIf cfg.runAsService {
      Unit.Description = "Walker - Application Runner";
      Unit.PartOf = [ "graphical-session.target" ];
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${getExe pkgs.walker} --gapplication-service";
        Restart = "on-failure";
      };
    };

    programs.walker.settings = {
      terminal = mkDefault "alacritty";
      activation_mode.labels = mkDefault "jkl;asdfnmer";
      theme = mkDefault "default";
      keys = mapAttrs (_: mkDefault) {
        accept_typeahead = [ "tab" ];
        trigger_labels = "lalt";
        next = [
          "down"
          "ctrl j"
        ];
        prev = [
          "up"
          "ctrl k"
        ];
        close = [
          "esc"
          "ctrl c"
        ];
        remove_from_history = [ "shift backspace" ];
        resume_query = [ "ctrl r" ];
        toggle_exact_search = [ "ctrl m" ];
      };
      builtins.websearch = {
        entries = mkDefault [
          {
            name = "DuckDuckGo";
            url = "https://duckduckgo.com/?q=%TERM%";
            switcher_only = true;
          }
        ];
      };
    };
    programs.walker.themes.custom = {
      layout.ui = {
        anchors = {
          bottom = true;
          left = true;
          right = true;
          top = true;
        };

        window = {
          box = {
            ai_scroll = {
              h_align = "fill";
              height = custom.height;
              list = {
                item = {
                  h_align = "fill";
                  name = "aiItem";
                  v_align = "fill";
                  wrap = true;
                  x_align = 0;
                  y_align = 0;
                };
                name = "aiList";
                orientation = "vertical";
                spacing = 10;
                width = custom.width;
              };
              margins = {
                top = 8;
              };
              max_height = custom.height + 50;
              min_width = custom.width;
              name = "aiScroll";
              v_align = "fill";
              width = custom.width;
            };
            bar = {
              entry = {
                h_align = "fill";
                h_expand = true;
                icon = {
                  h_align = "center";
                  h_expand = true;
                  pixel_size = 24;
                  theme = "";
                };
              };
              orientation = "horizontal";
              position = "end";
            };
            h_align = "center";
            margins.top = 200;
            scroll = {
              list = {
                item = {
                  activation_label = {
                    h_align = "fill";
                    v_align = "fill";
                    width = 20;
                    x_align = 0.5;
                    y_align = 0.5;
                  };
                  icon = {
                    pixel_size = 26;
                    theme = "";
                  };
                };
                margins.top = 8;
                max_height = custom.height;
                max_width = custom.width;
                min_width = custom.width;
                width = custom.width;
              };
            };
            search = {
              clear = {
                h_align = "center";
                icon = "edit-clear";
                name = "clear";
                pixel_size = 18;
                theme = "";
                v_align = "center";
              };
              input = {
                h_align = "fill";
                h_expand = true;
                icons = true;
              };
              prompt = {
                h_align = "center";
                icon = "edit-find";
                name = "prompt";
                pixel_size = 18;
                theme = "";
                v_align = "center";
              };
              spinner.hide = true;
            };
            width = custom.width;
          };
          h_align = "fill";
          v_align = "fill";
        };
      };
      style = ./custom.css;
    };

    khome.desktop.wm.menu = cfg.walkerExec;
    # khome.desktop.wm.shared.binds.walker = {
    #   enable = true;
    #   exec = true;
    #   mapping = cfg.key;
    #   command = cfg.walkerExec;
    # };

  };
}
