args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    flatten
    mapAttrs
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkOption
    mkIf
    mkMerge
    pipe
    types
    ;
  filterEnable = lib.filterAttrs (_: c: c.enable);
  enabledPlugins = filterEnable cfg.plugins;
  cfg = config.khome.shell.yazi;
  toml = pkgs.formats.toml { };
in
{
  options.khome.shell.yazi = {
    enable = mkEnableOption "enable yazi file manager";
    linemode = mkOption {
      description = "manager linemode, one of (permissions,size,mtime)";
      default = "size";
      type = types.str;
    };
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
    sort_by = mkOption {
      description = "sort by";
      default = "natural";
      type = types.str;
    };
    show_hidden = mkEnableOption "show hidden files" // {
      default = false;
    };
    show_symlink = mkEnableOption "show symlink files" // {
      default = true;
    };
    enablePluginsByDefault = mkEnableOption "enables default plugins" // {
      default = true;
    };
    bundleExtraPackages =
      mkEnableOption ''
        when enabled, adds plugin's `extraPackages` to `programs.yazi.extraPackages`
        which bundles dependencies with yazi binary.

        this bundling can cause conflicts if you include `pkgs.yazi` elsewhere
        in your configuration, disabling this option adds plugin `extraPackages`
        to `home.packages` instead.
      ''
      // {
        default = true;
      };
    plugins = mkOption {
      description = "Plugins to add";
      default = { };
      type = types.attrsOf (
        types.submodule (
          { config, name, ... }:
          {
            options = {
              enable = mkEnableOption "enable plugin" // {
                default = cfg.enablePluginsByDefault;
              };
              name = mkOption {
                description = "Name of plugin";
                default = name;
                type = types.str;
              };
              extraConfig = mkOption {
                description = "Extra config to add to init.lua";
                default = "";
                type =
                  with types;
                  oneOf [
                    str
                    path
                  ];
              };
              description = mkOption {
                description = "Description of plugin";
                default = "";
                type = types.str;
              };
              plugin = mkOption {
                description = ''
                  Path to file, package or text containing lua config.

                  If the plugin name is in `pkgs.yaziPlugins`, then defaults to that package.
                '';
                default = null;
                type =
                  with types;
                  nullOr (oneOf [
                    path
                    package
                  ]);
              };
              extraPackages = mkOption {
                description = "Extra packages to add when plugin is enabled";
                default = [ ];
                type = types.listOf types.package;
              };
              keymaps = mkOption {
                description = "keymaps to add if plugin is enabled";
                default = { };
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      enable = mkEnableOption "enable keymap" // {
                        default = true;
                      };
                      map = mkOption {
                        description = "Keymap toml config";
                        default = { };
                        type = toml.type;
                        example = lib.literalExpression ''
                          {
                                              desc = "Peek preview down";
                                              on = [ "<C-j>" ];
                                              run = "seek 5";
                                            }'';
                      };
                    };
                  }
                );
                example = lib.literalExpression ''
                  {
                                peek_down.map = {
                                  desc = "Peek preview down";
                                  on = [ "<C-j>" ];
                                  run = "seek 5";
                                };
                                peek_up.map = {
                                  desc = "Peek preview up";
                                  on = [ "<C-k>" ];
                                  run = "seek -5";
                                };
                              }'';
              };
              preloaders = mkOption {
                description = "preloaders to (prepend) add if plugin is enabled";
                default = { };
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      enable = mkEnableOption "enable previewer" // {
                        default = true;
                      };
                      conf = mkOption {
                        description = "Previewer toml config";
                        default = { };
                        type = toml.type;
                        example = lib.literalExpression ''
                          {
                                              mime = "{audio,video,image}/*";
                                              run = "mediainfo";
                                            }'';
                      };
                    };
                  }
                );
                example = lib.literalExpression ''
                  {
                                video.conf = {
                                  mime = "{audio,video,image}/*";
                                  run = "mediainfo";
                                };
                                subrip.conf = {
                                  mime = "application/subrip";
                                  run = "mediainfo";
                                };
                              }'';
              };
              previewers = mkOption {
                description = "previewers to (prepend) add if plugin is enabled";
                default = { };
                type = types.attrsOf (
                  types.submodule (
                    { config, name, ... }:
                    {
                      options = {
                        enable = mkEnableOption "enable previewer" // {
                          default = true;
                        };
                        conf = mkOption {
                          description = "Previewer toml config";
                          default = { };
                          type = toml.type;
                          example = lib.literalExpression ''
                            {
                                                mime = "{audio,video,image}/*";
                                                run = "mediainfo";
                                              }'';
                        };
                      };
                    }
                  )
                );
                example = lib.literalExpression ''
                  {
                                video.conf = {
                                  mime = "{audio,video,image}/*";
                                  run = "mediainfo";
                                };
                                subrip.conf = {
                                  mime = "application/subrip";
                                  run = "mediainfo";
                                };
                              }'';
              };
            };
            config.plugin = pkgs.yaziPlugins.${config.name} or (mkDefault null);
            # config.plugin = if (builtins.hasAttr config.name pkgs.yaziPlugins) then (mkDefault config.plugin) else mkDefault "";
          }
        )
      );
    };
    extraSettings = mkOption {
      type = types.attrsOf types.raw;
      description = "extra settings to merge in with `programs.yazi`";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = pipe enabledPlugins [
      (filterAttrs (_: p: p.plugin != null))
      (lib.mapAttrs' (
        _: p:
        lib.nameValuePair "yazi/plugins/${p.name}.yazi" (
          if builtins.typeOf p.plugin == "str" then
            {
              text = p.plugin;
            }
          else
            {
              source = p.plugin;
            }
        )
      ))
    ];

    home.packages = mkIf (!cfg.bundleExtraPackages) (
      flatten (mapAttrsToList (_: p: p.extraPackages) enabledPlugins)
    );

    programs.yazi = mkMerge [
      cfg.extraSettings
      {
        enable = true;
        enableBashIntegration = true;
        extraPackages = mkIf cfg.bundleExtraPackages (
          flatten (mapAttrsToList (_: p: p.extraPackages) enabledPlugins)
        );
        initLua = ''
          ${builtins.readFile ./init.lua}

          -- extra
          ${pipe enabledPlugins [
            (filterAttrs (_: p: p.extraConfig != "" || (builtins.typeOf p.extraConfig == "path")))
            (mapAttrsToList (
              _: p: ''
                -- ${p.name}: ${p.description}
                ${
                  if builtins.typeOf p.extraConfig == "path" then builtins.readFile p.extraConfig else p.extraConfig
                }
              ''
            ))
            (concatStringsSep "\n")
          ]}
        '';
        plugins = pipe enabledPlugins [
          (filterAttrs (_: p: p.plugin != null))
          (mapAttrs (_: p: p.plugin))
        ];
        flavors = mkIf (cfg.theme.src != null) {
          ${cfg.theme.name} = cfg.theme.src;
        };
        theme = mkIf (cfg.theme.name != null) {
          flavor.use = cfg.theme.name;
        };
        keymap.mgr.prepend_keymap = (
          pipe enabledPlugins [
            (mapAttrsToList (_: p: mapAttrsToList (_: k: k.map) (filterEnable p.keymaps)))
            flatten
          ]
        );
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
            prepend_preloaders = pipe enabledPlugins [
              (mapAttrsToList (_: p: mapAttrsToList (_: pl: pl.conf) (filterEnable p.preloaders)))
              flatten
            ];
            prepend_previewers = pipe enabledPlugins [
              (mapAttrsToList (_: p: mapAttrsToList (_: pv: pv.conf) (filterEnable p.previewers)))
              flatten
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

    ## Plugins
    khome.shell.yazi.plugins = {
      default-maps.keymaps = {
        peek-down.map = {
          desc = "Peek preview down";
          on = [ "<C-j>" ];
          run = "seek 5";
        };
        peek-up.map = {
          desc = "Peek preview up";
          on = [ "<C-k>" ];
          run = "seek -5";
        };
        help.map = {
          desc = "Show help";
          on = [ "<C-h>" ];
          run = "help";
        };
        open-shell.map = {
          desc = "Open shell here";
          on = [
            "C"
            "C"
          ];
          run = "shell --block --confirm $SHELL";
        };
        cd.map = {
          desc = "Cd into path";
          on = [
            "C"
            "c"
          ];
          run = "cd --interactive";
        };
        tab-create.map = {
          desc = "tab create";
          on = [
            "t"
            "t"
          ];
          run = "tab_create";
        };
        tab-delete.map = {
          desc = "tab delete";
          on = [
            "t"
            "d"
          ];
          run = "tab_close";
        };
        tab-next.map = {
          desc = "tab next";
          on = [
            "t"
            "n"
          ];
          run = "tab_switch --relative 1";
        };
        tab-prev.map = {
          desc = "tab prev";
          on = [
            "t"
            "p"
          ];
          run = "tab_switch --relative -1";
        };
        show-tasks.map = {
          desc = "Show tasks";
          on = [
            "T"
            "T"
          ];
          run = "tasks_show";
        };
        lazygit.map = {
          desc = "Open lazygit";
          on = [ "<C-g>" ];
          run = ''shell "lazygit" --block --confirm'';
        };
      };
      parent-arrow = {
        plugin = ./parent-arrow;
        keymaps = {
          nav-up.map = {
            desc = "navigate parent dir (up)";
            on = [ "K" ];
            run = "plugin --sync parent-arrow --args=-1";
          };
          nav-down.map = {
            desc = "navigate parent dir (down)";
            on = [ "J" ];
            run = "plugin --sync parent-arrow --args=1";
          };
        };
      };
      smart-enter.keymaps.enter.map = {
        desc = "Enter the child directory, or open the file";
        on = [ "l" ];
        run = "plugin --sync smart-enter";
      };
      chmod.keymaps.chmod.map = {
        desc = "Chmod on selected files";
        on = [
          "c"
          "m"
        ];
        run = "plugin chmod";
      };
      toggle-pane.keymaps = {
        toggle-min.map = {
          desc = "Hide or show preview";
          on = [
            "z"
            "m"
          ];
          run = "plugin toggle-pane min-preview";
        };
        toggle-max.map = {
          desc = "Maximize or restore preview";
          on = [
            "z"
            "M"
          ];
          run = "plugin toggle-pane max-preview";
        };
      };
      mount = { };
      open-with-cmd = {
        description = "run a cmd with a file path";
        keymaps = {
          open_terminal.map = {
            desc = "Open with command in the terminal";
            run = "plugin open-with-cmd --args=block";
            on = [ "o" ];
          };
          open_command.map = {
            desc = "Open with command";
            run = "plugin open-with-cmd";
            on = [ "O" ];
          };
        };
      };
      wl-clipboard = {
        description = "wl-clipboard.yazi: copy using wl-clipboard";
        extraPackages = [ pkgs.clipboard-jh ];
        keymaps.copy.map = {
          desc = "Copy to clipboard";
          run = "plugin wl-clipboard";
          on = [ "<C-y>" ];
        };
      };
      what-size.description = "what-size.yazi: calls du on current directory";
      rsync = {
        description = "rsync.yazi: use rsync to copy files to remote servers";
        extraPackages = [ pkgs.rsync ];
        keymaps.copy.map = {
          desc = "Copy files using rsync";
          run = "plugin rsync";
          on = [ "R" ];
        };
      };
      time-travel = {
        description = "time-travel.yazi: browse backwards/forewards in zfs/btrfs snapshots";
        keymaps = {
          exit.map = {
            desc = "Exit browsing snapshots";
            run = "plugin time-travel --args=exit";
            on = [
              "z"
              "e"
            ];
          };
          next.map = {
            desc = "Go to next snapshot";
            run = "plugin time-travel --args=next";
            on = [
              "z"
              "l"
            ];
          };
          prev.map = {
            desc = "Go to previous snapshot";
            run = "plugin time-travel --args=prev";
            on = [
              "z"
              "h"
            ];
          };
        };
      };
      mediainfo = {
        description = "mediainfo.yazi: show media info for many media files";
        extraPackages = [ pkgs.mediainfo ];
        preloaders = {
          media.conf = {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          };
          subrip.conf = {
            mime = "application/subrip";
            run = "mediainfo";
          };
        };
        previewers = {
          media.conf = {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          };
          subrip.conf = {
            mime = "application/subrip";
            run = "mediainfo";
          };
        };
      };
      fg = {
        description = "fg.yazi: fuzzy find files";
        extraPackages = [
          pkgs.ripgrep
          pkgs.fzf
        ];
        keymaps = {
          find_in_file.map = {
            desc = "find text in file by content (fuzzy)";
            on = [
              "f"
              "g"
            ];
            run = "plugin fg";
          };
          find_in_file_rg.map = {
            desc = "find text in file by content (ripgrep match)";
            on = [
              "f"
              "G"
            ];
            run = "plugin fg -- rg";
          };
          find_file.map = {
            desc = "find file by file name";
            on = [
              "f"
              "f"
            ];
            run = "plugin fg --args='fzf'";
          };
        };
      };
      glow = {
        description = "glow.yazi: preview md files";
        extraPackages = [ pkgs.glow ];
        previewers.md.conf = {
          mime = "*.md";
          run = "glow";
        };
      };
      ouch = {
        description = "ouch.yazi: preview archives";
        extraPackages = [ pkgs.ouch ];
        previewers.compressed.conf = {
          mime = "application/{*zip,x-tar,x-bzip2,x-7z-compressed,x-rar,vnd.rar,x-xz,xz,x-zstd,zstd,java-archive}";
          run = "ouch";
        };
      };
      zoxide = {
        description = "zoxide.yazi: zoxide integration + db";
        extraConfig = ''
          require("zoxide"):setup({
            update_db = true,
          })
        '';
      };
      gvfs = {
        description = "gvfs.yazi: manage gvfs and gio mounts";
        extraConfig = ./gvfs/init.lua;
        keymaps = {
          # select_mount.map = {
          #   on = [
          #     "M"
          #     "m"
          #   ];
          #   run = "plugin gvfs -- select-then-mount";
          #   desc = "Select device then mount";
          # };
          # or this if you want to jump to mountpoint after mounted
          select_mount.map = {
            on = [
              "M"
              "m"
            ];
            run = "plugin gvfs -- select-then-mount --jump";
            desc = "Select device to mount and jump to its mount point";
          };
          # This will remount device under cwd (e.g. cwd = /run/user/1000/gvfs/DEVICE_1/FOLDER_A, device mountpoint = /run/user/1000/gvfs/DEVICE_1)
          remount_current_cwd.map = {
            on = [
              "M"
              "R"
            ];
            run = "plugin gvfs -- remount-current-cwd-device";
            desc = "Remount device under cwd";
          };
          select_and_unmount.map = {
            on = [
              "M"
              "u"
            ];
            run = "plugin gvfs -- select-then-unmount";
            desc = "Select device then unmount";
          };
          # or this if you want to unmount and eject device. Ejected device can safely be removed.
          # Ejecting a device will unmount all paritions/volumes under it.
          # Fallback to normal unmount if not supported by device.
          select_and_eject.map = {
            on = [
              "M"
              "u"
            ];
            run = "plugin gvfs -- select-then-unmount --eject";
            desc = "Select device then eject";
          };
          # Also support force unmount/eject.
          # force = true -> Ignore outstanding file operations when unmounting or ejecting
          select_force_unmount.map = {
            on = [
              "M"
              "U"
            ];
            run = "plugin gvfs -- select-then-unmount --eject --force";
            desc = "Select device then force to eject/unmount";
          };

          # Add|Edit|Remove mountpoint: smb, sftp, ftp, nfs, dns-sd, dav, davs, dav+sd, davs+sd, afp, afc, sshfs
          # Read more about the schemes here: https://wiki.gnome.org/Projects(2f)gvfs(2f)schemes.html
          # For example: smb://user@192.168.1.2/share, smb://WORKGROUP;user@192.168.1.2/share, sftp://user@192.168.1.2/, ftp://192.168.1.2/
          # - Scheme/Mount URIs shouldn't contain password.
          # - Google Drive, One drive are mounted automatically via GNOME Online Accounts (GOA). Avoid adding them. Use GOA instead: ./GNOME_ONLINE_ACCOUNTS_GOA.md
          # - MTP, GPhoto2, AFC, Hard disk/drive are listed automatically. Avoid adding them
          add_mount.map = {
            on = [
              "M"
              "a"
            ];
            run = "plugin gvfs -- add-mount";
            desc = "Add a GVFS mount URI";
          };
          # Edit or remove a GVFS mount URI will clear saved passwords for that mount URI.
          edit_mount.map = {
            on = [
              "M"
              "e"
            ];
            run = "plugin gvfs -- edit-mount";
            desc = "Edit a GVFS mount URI";
          };
          remove_mount.map = {
            on = [
              "M"
              "r"
            ];
            run = "plugin gvfs -- remove-mount";
            desc = "Remove a GVFS mount URI";
          };

          # Jump
          jump.map = {
            on = [
              "g"
              "m"
            ];
            run = "plugin gvfs -- jump-to-device";
            desc = "Select device then jump to its mount point";
          };
          # If you use `x-systemd.automount` in /etc/fstab or manually added automount unit, you can use `--automount` to automount device automatically
          jump_automount.map = {
            on = [
              "g"
              "m"
            ];
            run = "plugin gvfs -- jump-to-device --automount";
            desc = "Automount then select device to jump to its mount point";
          };
          jump_prev_cwd.map = {
            on = [
              "`"
              "`"
            ];
            run = "plugin gvfs -- jump-back-prev-cwd";
            desc = "Jump back to the position before jumped to device";
          };
        };
      };
      relative-motions = {
        description = "relative-motions.yazi: vim like relative-motions";
        extraConfig = ''
          require("relative-motions"):setup({
            show_numbers="relative_absolute",
            show_motion = true,
            enter_mode ="first",
          })
        '';
        keymaps = {
          relative_1.map = {
            on = [ "1" ];
            run = "plugin relative-motions 1";
            desc = "Move in relative steps";
          };

          relative_2.map = {
            on = [ "2" ];
            run = "plugin relative-motions 2";
            desc = "Move in relative steps";
          };

          relative_3.map = {
            on = [ "3" ];
            run = "plugin relative-motions 3";
            desc = "Move in relative steps";
          };

          relative_4.map = {
            on = [ "4" ];
            run = "plugin relative-motions 4";
            desc = "Move in relative steps";
          };

          relative_5.map = {
            on = [ "5" ];
            run = "plugin relative-motions 5";
            desc = "Move in relative steps";
          };

          relative_6.map = {
            on = [ "6" ];
            run = "plugin relative-motions 6";
            desc = "Move in relative steps";
          };

          relative_7.map = {
            on = [ "7" ];
            run = "plugin relative-motions 7";
            desc = "Move in relative steps";
          };

          relative_8.map = {
            on = [ "8" ];
            run = "plugin relative-motions 8";
            desc = "Move in relative steps";
          };

          relative_9.map = {
            on = [ "9" ];
            run = "plugin relative-motions 9";
            desc = "Move in relative steps";
          };
        };
      };
      mime = {
        enable = mkDefault false;
        description = "mime.yazi: speedup preview of large files";
      };
      searchjump = {
        enable = mkDefault false;
        description = "A Yazi plugin whose behavior is consistent with flash.nvim in Neovim: from a search string it generates labels to jump to.";
        keymaps.mode.map = {
          desc = "Searchjump mode";
          run = "plugin searchjump";
          on = [ "i" ];
        };
      };
      jump-to-char = {
        description = "jump-to-char.yazi: Vim-like f<char>, jump to the next file whose name starts with <char>.";
        keymaps.jump-to-char.map = {
          desc = "Jump to char";
          run = "plugin jump-to-char";
          on = [ "f" ];
        };
      };
      bookmarks = {
        enable = mkDefault false;
        description = "ble bookmarks-persistence.yazi: persistent bookmarks";
        keymaps = {
          save_position.map = {
            desc = "Save current position as a bookmark";
            on = [
              "u"
              "a"
            ];
            run = "plugin bookmarks -- save";
          };
          jump.map = {
            desc = "Jump to a bookmark";
            on = [
              "u"
              "g"
            ];
            run = "plugin bookmarks -- jump";
          };
          delete.map = {
            desc = "Delete a bookmark";
            on = [
              "u"
              "d"
            ];
            run = "plugin bookmarks -- delete";
          };
          delete_all.map = {
            desc = "Delete all bookmarks";
            on = [
              "u"
              "D"
            ];
            run = "plugin bookmarks -- delete_all";
          };
          modify.map = {
            desc = "Modify key bind to hoverd path";
            on = [
              "u"
              "m"
            ];
            run = "plugin bookmarks -- modify";
          };
        };
      };
    };
  };
}
