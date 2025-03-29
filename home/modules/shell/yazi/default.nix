args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) fetchFromGitHub;
  inherit (lib)
    flatten
    mkDefault
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    optional
    optionals
    types
    ;
  cfg = config.khome.shell.yazi;
  plugs = cfg.plugins;
  mkStringOption =
    default: description:
    mkOption {
      inherit default description;
      type = types.str;
    };
in
{
  options.khome.shell.yazi = {
    enable = mkEnableOption "enable yazi file manager";
    linemode = mkStringOption "size" "manager linemode, one of (permissions,size,mtime)";
    theme = {
      src = mkOption {
        type =
          with types;
          nullOr (oneOf [
            path
            package
          ]);
        description = "source for theme";
        default = null;
      };
      name = mkOption {
        type = types.nullOr types.str;
        description = "optional theme flavour";
        default = null;
      };
    };
    sort_by = mkStringOption "natural" "sort by";
    show_hidden = mkEnableOption "show hidden files" // {
      default = false;
    };
    show_symlink = mkEnableOption "show symlink files" // {
      default = true;
    };
    plugins = {
      fg.enable = mkEnableOption "enable fg.yazi plugin (fuzzy find files)" // {
        default = true;
      };
      glow.enable = mkEnableOption "enable glow.yazi plugin (preview md files)" // {
        default = true;
      };
      mime.enable = mkEnableOption "enable mime.yazi plugin (speedup preview of large files)" // {
        default = false;
      };
      bookmarks.enable =
        mkEnableOption "enable bookmarks-persistence.yazi plugin (persistent bookmarks)"
        // {
          default = false;
        };
    };
    __ups = mkOption {
      type = types.raw;
      description = "extra settings to merge in with `programs.yazi`";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = mkMerge [
      cfg.__ups
      {
        enable = true;
        enableBashIntegration = true;
        initLua = ./init.lua;
        plugins = mkMerge [
          {
            # smart-enter = ./smart-enter;
            parent-arrow = ./parent-arrow;
            smart-enter = pkgs.yaziPlugins.smart-enter;
            chmod = pkgs.yaziPlugins.chmod;
            max-preview = pkgs.yaziPlugins.max-preview;
            hide-preview = pkgs.yaziPlugins.hide-preview;
            mount = pkgs.yaziPlugins.mount;
          }
          (mkIf plugs.mime.enable {
            mime-ext = pkgs.yaziPlugins.mime-ext;
          })
          (mkIf plugs.fg.enable {
            fg = pkgs.yaziPlugins.fg;
          })
          (mkIf plugs.glow.enable {
            glow = pkgs.yaziPlugins.glow;
          })
          (mkIf plugs.bookmarks.enable {
            bookmarks = pkgs.yaziPlugins.bookmarks;
          })
        ];
        flavors = mkIf (cfg.theme.src != null) {
          ${cfg.theme.name} = cfg.theme.src;
        };
        theme = mkIf (cfg.theme.name != null) {
          flavor.use = cfg.theme.name;
        };
        keymap.manager.prepend_keymap = flatten [
          {
            desc = "Enter the child directory, or open the file";
            on = [ "l" ];
            run = "plugin --sync smart-enter";
          }
          {
            desc = "navigate parent dir (up)";
            on = [ "K" ];
            run = "plugin --sync parent-arrow --args=-1";
          }
          {
            desc = "navigate parent dir (down)";
            on = [ "J" ];
            run = "plugin --sync parent-arrow --args=1";
          }
          {
            desc = "Show help";
            on = [ "<C-h>" ];
            run = "help";
          }
          {
            desc = "Open lazygit";
            on = [ "<C-g>" ];
            run = ''shell "lazygit" --block --confirm'';
          }
          {
            desc = "Open shell here";
            on = [
              "C"
              "C"
            ];
            run = "shell --block --confirm $SHELL";
          }
          {
            desc = "Cd into path";
            on = [
              "C"
              "c"
            ];
            run = "cd --interactive";
          }
          {
            desc = "tab create";
            on = [
              "t"
              "t"
            ];
            run = "tab_create";
          }
          {
            desc = "tab delete";
            on = [
              "t"
              "d"
            ];
            run = "tab_close";
          }
          {
            desc = "tab next";
            on = [
              "t"
              "n"
            ];
            run = "tab_switch --relative 1";
          }
          {
            desc = "tab prev";
            on = [
              "t"
              "p"
            ];
            run = "tab_switch --relative -1";
          }
          {
            desc = "Show tasks";
            on = [
              "T"
              "T"
            ];
            run = "tasks_show";
          }
          {
            desc = "Hide or show preview";
            on = [
              "M"
              "m"
            ];
            run = "plugin --sync hide-preview";
          }
          {
            desc = "Maximize or restore preview";
            on = [
              "M"
              "M"
            ];
            run = "plugin --sync max-preview";
          }
          {
            desc = "Chmod on selected files";
            on = [
              "c"
              "m"
            ];
            run = "plugin chmod";
          }
          (optionals plugs.fg.enable [
            {
              desc = "find file by content";
              on = [
                "f"
                "g"
              ];
              run = "plugin fg";
            }
            {
              desc = "find file by file name";
              on = [
                "f"
                "f"
              ];
              run = "plugin fg --args='fzf'";
            }
          ])
          (optionals plugs.bookmarks.enable [
            {
              desc = "Save current position as a bookmark";
              on = [
                "u"
                "a"
              ];
              run = "plugin bookmarks-persistence --args=save";
            }
            {
              desc = "Jump to a bookmark";
              on = [
                "u"
                "g"
              ];
              run = "plugin bookmarks-persistence --args=jump";
            }
            {
              desc = "Delete a bookmark";
              on = [
                "u"
                "d"
              ];
              run = "plugin bookmarks-persistence --args=delete";
            }
            {
              desc = "Delete all bookmarks";
              on = [
                "u"
                "D"
              ];
              run = "plugin bookmarks-persistence --args=delete_all";
            }
          ])
        ];
        settings = {
          log.enabled = true;
          manager = {
            inherit (cfg)
              sort_by
              show_hidden
              show_symlink
              linemode
              ;
            sort_sensitive = mkDefault false;
            sort_reverse = mkDefault false;
            dir_first = mkDefault false;
            # sort_translit = true;
          };
          plugin = {
            prepend_previewers = flatten [
              (optional cfg.plugins.glow.enable {
                mime = "*.md";
                run = "glow";
              })
            ];
          };
          opener = {
            edit = [
              {
                run = ''nvim "$@"'';
                block = true;
              }
            ];
            play = [
              {
                run = ''mpv "$@"'';
                orphan = true;
                for = "unix";
              }
            ];
            open = [
              {
                run = ''xdg-open "$@"'';
                desc = "Open";
              }
            ];
          };
        };
      }
    ];
  };
}
