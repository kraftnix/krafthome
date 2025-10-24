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
    optionalString
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
        # NOTE: error in usage
        default = false;
      };
      glow.enable = mkEnableOption "enable glow.yazi plugin (preview md files)" // {
        default = true;
      };
      ouch.enable = mkEnableOption "enable ouch.yazi plugin (preview archives)" // {
        default = true;
      };
      zoxide.enable = mkEnableOption "enable zoxide.yazi plugin (zoxide integration + db)" // {
        default = true;
      };
      gvfs.enable = mkEnableOption "enable gvfs.yazi plugin (manage gvfs and gio mounts)" // {
        # NOTE: Error: Lua runtime failed
        default = true;
      };
      relative-motions.enable =
        mkEnableOption "enable relative-motions.yazi plugin (vim like relative-motions)"
        // {
          default = true;
        };
      mime.enable = mkEnableOption "enable mime.yazi plugin (speedup preview of large files)" // {
        default = false;
      };
      searchjump.enable =
        mkEnableOption "A Yazi plugin whose behavior is consistent with flash.nvim in Neovim: from a search string it generates labels to jump to."
        // {
          default = false;
        };
      # whoosh.enable = mkEnableOption "enable whoosh.yazi plugin (advanced bookmarks)" // {
      #   default = false;
      # };
      jump-to-char.enable =
        mkEnableOption "enable jump-to-char.yazi plugin (Vim-like f<char>, jump to the next file whose name starts with <char>.)"
        // {
          default = true;
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
      ++ (optional plugs.ouch.enable pkgs.ouch)
      ++ (optional plugs.mediainfo.enable pkgs.mediainfo)
      ++ (optional plugs.wl-clipboard.enable pkgs.clipboard-jh);
    programs.yazi = mkMerge [
      cfg.__ups
      {
        enable = true;
        enableBashIntegration = true;
        initLua = ''
          ${builtins.readFile ./init.lua}
          -- extra

          ${optionalString plugs.relative-motions.enable ''
            require("relative-motions"):setup({
              show_numbers="relative_absolute",
              show_motion = true,
              enter_mode ="first",
            })
          ''}

          ${optionalString plugs.zoxide.enable ''
            require("zoxide"):setup({
              update_db = true,
            })
          ''}

          ${optionalString plugs.gvfs.enable ''
            ${builtins.readFile ./gvfs/init.lua}
          ''}
        '';
        # ${optionalString plugs.whoosh.enable ''
        #   --Whoosh
        #   ${builtins.readFile ./whoosh/init.lua}
        # ''}
        plugins = mkMerge [
          {
            # smart-enter = ./smart-enter;
            parent-arrow = ./parent-arrow;
            smart-enter = pkgs.yaziPlugins.smart-enter;
            chmod = pkgs.yaziPlugins.chmod;
            toggle-pane = pkgs.yaziPlugins.toggle-pane;
            mount = pkgs.yaziPlugins.mount;
          }
          (mkIf plugs.relative-motions.enable {
            relative-motions = pkgs.yaziPlugins.relative-motions;
          })
          (mkIf plugs.jump-to-char.enable {
            jump-to-char = pkgs.yaziPlugins.jump-to-char;
          })
          # (mkIf plugs.whoosh.enable {
          #   whoosh = pkgs.yaziPlugins.whoosh;
          # })
          (mkIf plugs.searchjump.enable {
            searchjump = pkgs.yaziPlugins.searchjump;
          })
          (mkIf plugs.gvfs.enable {
            gvfs = pkgs.yaziPlugins.gvfs;
          })
          (mkIf plugs.ouch.enable {
            ouch = pkgs.yaziPlugins.ouch;
          })
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
            desc = "Peek preview down";
            on = [ "<C-j>" ];
            run = "seek 5";
          }
          {
            desc = "Peek preview up";
            on = [ "<C-k>" ];
            run = "seek -5";
          }
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
              "z"
              "m"
            ];
            run = "plugin toggle-pane min-preview";
          }
          {
            desc = "Maximize or restore preview";
            on = [
              "z"
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
          (optionals plugs.relative-motions.enable [
            {
              on = [ "1" ];
              run = "plugin relative-motions 1";
              desc = "Move in relative steps";
            }

            {
              on = [ "2" ];
              run = "plugin relative-motions 2";
              desc = "Move in relative steps";
            }

            {
              on = [ "3" ];
              run = "plugin relative-motions 3";
              desc = "Move in relative steps";
            }

            {
              on = [ "4" ];
              run = "plugin relative-motions 4";
              desc = "Move in relative steps";
            }

            {
              on = [ "5" ];
              run = "plugin relative-motions 5";
              desc = "Move in relative steps";
            }

            {
              on = [ "6" ];
              run = "plugin relative-motions 6";
              desc = "Move in relative steps";
            }

            {
              on = [ "7" ];
              run = "plugin relative-motions 7";
              desc = "Move in relative steps";
            }

            {
              on = [ "8" ];
              run = "plugin relative-motions 8";
              desc = "Move in relative steps";
            }

            {
              on = [ "9" ];
              run = "plugin relative-motions 9";
              desc = "Move in relative steps";
            }
          ])
          (optionals plugs.fg.enable [
            {
              desc = "find text in file by content (fuzzy)";
              on = [
                "f"
                "g"
              ];
              run = "plugin fg";
            }
            {
              desc = "find text in file by content (ripgrep match)";
              on = [
                "f"
                "G"
              ];
              run = "plugin fg -- rg";
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
          (optionals plugs.gvfs.enable [
            {
              on = [
                "M"
                "m"
              ];
              run = "plugin gvfs -- select-then-mount";
              desc = "Select device then mount";
            }
            # or this if you want to jump to mountpoint after mounted
            {
              on = [
                "M"
                "m"
              ];
              run = "plugin gvfs -- select-then-mount --jump";
              desc = "Select device to mount and jump to its mount point";
            }
            # This will remount device under cwd (e.g. cwd = /run/user/1000/gvfs/DEVICE_1/FOLDER_A, device mountpoint = /run/user/1000/gvfs/DEVICE_1)
            {
              on = [
                "M"
                "R"
              ];
              run = "plugin gvfs -- remount-current-cwd-device";
              desc = "Remount device under cwd";
            }
            {
              on = [
                "M"
                "u"
              ];
              run = "plugin gvfs -- select-then-unmount";
              desc = "Select device then unmount";
            }
            # or this if you want to unmount and eject device. Ejected device can safely be removed.
            # Ejecting a device will unmount all paritions/volumes under it.
            # Fallback to normal unmount if not supported by device.
            {
              on = [
                "M"
                "u"
              ];
              run = "plugin gvfs -- select-then-unmount --eject";
              desc = "Select device then eject";
            }
            # Also support force unmount/eject.
            # force = true -> Ignore outstanding file operations when unmounting or ejecting
            {
              on = [
                "M"
                "U"
              ];
              run = "plugin gvfs -- select-then-unmount --eject --force";
              desc = "Select device then force to eject/unmount";
            }

            # Add|Edit|Remove mountpoint: smb, sftp, ftp, nfs, dns-sd, dav, davs, dav+sd, davs+sd, afp, afc, sshfs
            # Read more about the schemes here: https://wiki.gnome.org/Projects(2f)gvfs(2f)schemes.html
            # For example: smb://user@192.168.1.2/share, smb://WORKGROUP;user@192.168.1.2/share, sftp://user@192.168.1.2/, ftp://192.168.1.2/
            # - Scheme/Mount URIs shouldn't contain password.
            # - Google Drive, One drive are mounted automatically via GNOME Online Accounts (GOA). Avoid adding them. Use GOA instead: ./GNOME_ONLINE_ACCOUNTS_GOA.md
            # - MTP, GPhoto2, AFC, Hard disk/drive are listed automatically. Avoid adding them
            {
              on = [
                "M"
                "a"
              ];
              run = "plugin gvfs -- add-mount";
              desc = "Add a GVFS mount URI";
            }
            # Edit or remove a GVFS mount URI will clear saved passwords for that mount URI.
            {
              on = [
                "M"
                "e"
              ];
              run = "plugin gvfs -- edit-mount";
              desc = "Edit a GVFS mount URI";
            }
            {
              on = [
                "M"
                "r"
              ];
              run = "plugin gvfs -- remove-mount";
              desc = "Remove a GVFS mount URI";
            }

            # Jump
            {
              on = [
                "g"
                "m"
              ];
              run = "plugin gvfs -- jump-to-device";
              desc = "Select device then jump to its mount point";
            }
            # If you use `x-systemd.automount` in /etc/fstab or manually added automount unit, you can use `--automount` to automount device automatically
            {
              on = [
                "g"
                "m"
              ];
              run = "plugin gvfs -- jump-to-device --automount";
              desc = "Automount then select device to jump to its mount point";
            }
            {
              on = [
                "`"
                "`"
              ];
              run = "plugin gvfs -- jump-back-prev-cwd";
              desc = "Jump back to the position before jumped to device";
            }
          ])
          (optionals plugs.jump-to-char.enable [
            {
              desc = "Jump to char";
              run = "plugin jump-to-char";
              on = [ "f" ];
            }
          ])
          (optionals plugs.searchjump.enable [
            {
              desc = "Searchjump mode";
              run = "plugin searchjump";
              on = [ "i" ];
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
              run = "plugin bookmarks -- save";
            }
            {
              desc = "Jump to a bookmark";
              on = [
                "u"
                "g"
              ];
              run = "plugin bookmarks -- jump";
            }
            {
              desc = "Delete a bookmark";
              on = [
                "u"
                "d"
              ];
              run = "plugin bookmarks -- delete";
            }
            {
              desc = "Delete all bookmarks";
              on = [
                "u"
                "D"
              ];
              run = "plugin bookmarks -- delete_all";
            }
            {
              desc = "Modify key bind to hoverd path";
              on = [
                "u"
                "m"
              ];
              run = "plugin bookmarks -- modify";
            }
          ])
        ];
        settings = {
          log.enabled = true;
          tasks = {
            # Unlimited picture size
            image_alloc = 0; # this doesn't appear to have any affect when image_bound is set
            image_bound = [
              0
              0
            ];
          };
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
              (optional cfg.plugins.ouch.enable {
                mime = "application/{*zip,x-tar,x-bzip2,x-7z-compressed,x-rar,vnd.rar,x-xz,xz,x-zstd,zstd,java-archive}";
                run = "ouch";
              })
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
