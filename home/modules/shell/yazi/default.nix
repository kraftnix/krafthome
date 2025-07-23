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
      open-with-cmd.enable =
        mkEnableOption "enable open-with-cmd.yazi plugin (run a cmd with a file path)"
        // {
          default = true;
        };
      wl-clipboard.enable = mkEnableOption "enable wl-clipboard.yazi plugin (smart clipboard)" // {
        default = true;
      };
      what-size.enable =
        mkEnableOption "enable what-size.yazi plugin (calls du on current directory)"
        // {
          default = true;
        };
      rsync.enable =
        mkEnableOption "enable rsync.yazi plugin (use rsync to copy files to remote servers)"
        // {
          default = true;
        };
      time-travel.enable =
        mkEnableOption "enable time-travel.yazi plugin (browse backwards/forewards in zfs/btrfs snapshots)"
        // {
          default = true;
        };
      mediainfo.enable =
        mkEnableOption "enable mediainfo.yazi plugin (show media info for many media files)"
        // {
          default = true;
        };
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
    home.packages =
      [ ]
      ++ (optional plugs.mediainfo.enable pkgs.mediainfo)
      ++ (optional plugs.wl-clipboard.enable pkgs.clipboard-jh);
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
            toggle-pane = pkgs.yaziPlugins.toggle-pane;
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
          (mkIf plugs.open-with-cmd.enable {
            open-with-cmd = pkgs.yaziPlugins.open-with-cmd;
          })
          (mkIf plugs.wl-clipboard.enable {
            wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
          })
          (mkIf plugs.mediainfo.enable {
            mediainfo = pkgs.yaziPlugins.mediainfo;
          })
          (mkIf plugs.time-travel.enable {
            time-travel = pkgs.yaziPlugins.time-travel;
          })
          (mkIf plugs.rsync.enable {
            rsync = pkgs.yaziPlugins.rsync;
          })
          (mkIf plugs.what-size.enable {
            what-size = pkgs.yaziPlugins.what-size;
          })
        ];
        flavors = mkIf (cfg.theme.src != null) {
          ${cfg.theme.name} = cfg.theme.src;
        };
        theme = mkIf (cfg.theme.name != null) {
          flavor.use = cfg.theme.name;
        };
        keymap.mgr.prepend_keymap = flatten [
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
            run = "plugin toggle-pane min-preview";
          }
          {
            desc = "Maximize or restore preview";
            on = [
              "M"
              "M"
            ];
            run = "plugin toggle-pane max-preview";
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
          (optionals plugs.wl-clipboard.enable [
            {
              desc = "Copy to clipboard";
              run = "plugin wl-clipboard";
              on = [ "<C-y>" ];
            }
          ])
          (optionals plugs.open-with-cmd.enable [
            {
              desc = "Open with command in the terminal";
              run = "plugin open-with-cmd --args=block";
              on = [ "o" ];
            }
            {
              desc = "Open with command";
              run = "plugin open-with-cmd";
              on = [ "O" ];
            }
          ])
          (optionals plugs.rsync.enable [
            {
              desc = "Copy files using rsync";
              run = "plugin rsync";
              on = [ "R" ];
            }
          ])
          (optionals plugs.time-travel.enable [
            {
              desc = "Exit browsing snapshots";
              run = "plugin time-travel --args=exit";
              on = [
                "z"
                "e"
              ];
            }
            {
              desc = "Go to next snapshot";
              run = "plugin time-travel --args=next";
              on = [
                "z"
                "l"
              ];
            }
            {
              desc = "Go to previous snapshot";
              run = "plugin time-travel --args=prev";
              on = [
                "z"
                "h"
              ];
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
          mgr = {
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
            prepend_preloaders = flatten [
              (optionals cfg.plugins.mediainfo.enable [
                {
                  mime = "{audio,video,image}/*";
                  run = "mediainfo";
                }
                {
                  mime = "application/subrip";
                  run = "mediainfo";
                }
              ])
            ];
            prepend_previewers = flatten [
              (optional cfg.plugins.glow.enable {
                mime = "*.md";
                run = "glow";
              })
              (optionals cfg.plugins.mediainfo.enable [
                {
                  mime = "{audio,video,image}/*";
                  run = "mediainfo";
                }
                {
                  mime = "application/subrip";
                  run = "mediainfo";
                }
              ])
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
