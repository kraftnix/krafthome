{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  tmuxConfig = builtins.readFile ./tmux.conf;
  colors = with config.lib.base16.getColorsH "tmux"; {
    fg = foreground;
    bg = background;
    alt = secondary;
    highlight = primary;
  };
in
{
  programs.tmux = {
    enable = true;
    keyMode = "vi";

    # Rather than constraining window size to the maximum size of any client
    # connected to the *session*, constrain window size to the maximum size of any
    # client connected to *that window*. Much more reasonable.
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 10000;
    newSession = true;
    secureSocket = true;
    plugins = with pkgs; [
      { plugin = tmuxPlugins.yank; }
      { plugin = tmuxPlugins.resurrect; }
      { plugin = tmuxPlugins.open; }
      { plugin = tmuxPlugins.continuum; }
    ];
    terminal = "xterm-256color";
    #shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    extraConfig =
      tmuxConfig
      + ''
        bind-key -n 'C-M-u' copy-mode
        # Plugins
        ## continuum
        set -g @continuum-restore 'on'

        ## open
        set -g @open-S 'https://startpage.com/sp/search?q='
        set -g @open-s 'https://www.duckduckgo.com/search?q='

        ### THEME
        set-option -g status-position bottom
        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",xterm-256color:Tc"

        # sizes / posiiton
        set -g status-interval 1
        set -g status-justify centre # center align window list
        set -g status-left-length 20
        set -g status-right-length 140

      ''
      + (
        with colors;
        optionalString config.themes.enable ''
          # message style
          set-option -g message-style bg="${highlight}",fg="${bg}"
          set-option -g message-command-style bg="${alt}",fg="${bg}"

          # monitor window changes
          set-option -wg monitor-activity on
          set-option -wg monitor-bell on
          set-option -wg mode-style bg="${highlight}",fg="${bg}"

          set-option -g pane-active-border-style fg="${fg}"
          set-option -g pane-border-style fg="${bg}"

          # pane number display
          set-option -g display-panes-active-colour "${highlight}"
          set-option -g display-panes-colour "${highlight}"

          # clock
          set-option -wg clock-mode-colour "${highlight}"

          # status line
          set-option -wg window-status-separator ""
          set-option -wg window-status-style bg="${bg}",fg="${fg}"
          set-option -wg window-status-activity-style bg="${bg}",fg="${alt}"
          set-option -wg window-status-bell-style bg="${bg}",fg="${fg}"
          set-option -wg window-status-current-style fg="${bg}",bg="${highlight}"
          set-option -wg window-status-current-format " #{window_index} #{window_name} "
          set-option -wg window-status-format " #{window_index} #{window_name} "

          set-option -g status-interval 1
          set-option -g status-style bg=terminal,fg="${alt}"
          set-option -g status-left "#[fg=${bg} bg=${alt}]#{?client_prefix,#[bg=${highlight}] #{session_name} #[bg=${alt}], #{session_name} }"
          #set-option -g status-right "#[fg=${fg}, bg=${bg}] %H:%M %d-%m-%Y #[fg=${bg}, bg=${alt}]#{?client_prefix,#[bg=${highlight}] #{host_short} #[bg=${alt}], #{host_short} }"
          set-option -g status-right "Continuum: #{continuum_restore} #[fg=${fg}, bg=${bg}] %H:%M %d-%m-%Y #[fg=${bg}, bg=${alt}]#{?client_prefix,#[bg=${highlight}] #{host_short} #[bg=${alt}], #{host_short} }"
        ''
      );
  };
}
