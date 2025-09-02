{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.shell.tmux;
  tmuxConfig = builtins.readFile ./tmux.conf;
  colors = config.lib.stylix.colors.withHashtag;
  # colors = with config.lib.stylix.colors.withHashtag; {
  #   fg = foreground;
  #   bg = background;
  #   alt = secondary;
  #   highlight = primary;
  # };
  version = "0.8.0";
  src = pkgs.fetchFromGitHub {
    owner = "fcsonline";
    repo = "tmux-thumbs";
    rev = "5fdab4dbc1493fbc2a82f3e09ac9b2483bd278c3";
    sha256 = "sha256-XMz1ZOTz2q1Dt4QdxG83re9PIsgvxTTkytESkgKxhGM=";
  };
  pname = "tmux-thumbs-rust";
  tmuxThumbsRust = pkgs.rustPlatform.buildRustPackage {
    inherit src pname version;
    cargoHash = "sha256-xvfjWS1QZWrlwytFyWVtjOyB3EPT9leodVLt72yyM4E=";
  };
  tmux-thumbs = pkgs.tmuxPlugins.mkTmuxPlugin {
    inherit version src;
    TMUX_THUMBS_BIN = "share/tmux-plugins/tmux-thumbs/target/release";
    pluginName = "tmux-thumbs";
    postInstall = ''
      mkdir -p $out/$TMUX_THUMBS_BIN
      cp ${tmuxThumbsRust}/bin/* $out/$TMUX_THUMBS_BIN
    '';
    rtpFilePath = "tmux-thumbs.tmux";
  };
  tmuxPlugins = pkgs.tmuxPlugins // {
    thumbs = tmux-thumbs;
    mullvad = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-mullvad";
      version = "0.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "jaclu";
        repo = "tmux-mullvad";
        rev = "01b270c30ebdad9307e9c31f52099fcb4b66bcad";
        sha256 = "sha256-zqUG2Er4zWZue9zT+cmHho1vrZxoJDno9wXoDbOX6rc=";
      };
      rtpFilePath = "mullvad.tmux";
    };
    extrakto = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "extrakto";
      version = "0.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "laktak";
        repo = "extrakto";
        rev = "b297d4590d7b2c7a345899bb3066777a7ffcce04";
        hash = "sha256-CMLRUcQUqxpUETcPZD/DfxqO+H74258QbOTVGJ/APWk=";
      };
      rtpFilePath = "extrakto.tmux";
    };
    power-zoom = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-power-zoom";
      version = "1.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "jaclu";
        repo = "tmux-power-zoom";
        rev = "6d618af224229ae653ffcc6d12c2146d536af79b";
        sha256 = "sha256-zFmEs6A5LJM6zI/aJ6j3Pf1yrNfF2G4ehRJJRz+qEwg=";
      };
      rtpFilePath = "power-zoom.tmux";
    };
    session-wizard = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-session-wizard";
      version = "1.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "27medkamal";
        repo = "tmux-session-wizard";
        rev = "3bd5c84b56105ae8e63e28a6cc0631e5c4a3af44";
        sha256 = "sha256-JOmYV4dDQodNJVb+6zKgXqUS8bipAGeh8M8Mik1skfQ=";
      };
      rtpFilePath = "session-wizard.tmux";
    };
    window-name = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-window-name";
      version = "0.1-640003d2";
      src = pkgs.fetchFromGitHub {
        owner = "ofirgall";
        repo = "tmux-window-name";
        rev = "640003d2fe53ef3ddc08417063a15cc909757f76";
        sha256 = "sha256-V70zvvighDkBfuqjWYzC/61/+GkeIiqaOOaY5Ls25yI=";
      };
      rtpFilePath = "tmux_window_name.tmux";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postInstall = ''
        wrapProgram $target/tmux_window_name.tmux \
          --prefix PYTHONPATH : ${(pkgs.python3.withPackages (ps: with ps; [ libtmux ])).sitePackages}
      '';
    };
    autoreload = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-autoreload";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "b0o";
        repo = "tmux-autoreload";
        rev = "e98aa3b74cfd5f2df2be2b5d4aa4ddcc843b2eba";
        sha256 = "sha256-9Rk+VJuDqgsjc+gwlhvX6uxUqpxVD1XJdQcsc5s4pU4=";
      };
      rtpFilePath = "tmux-autoreload.tmux";
    };
    tokyo-night-2 = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-tokyo-night";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "fabioluciano";
        repo = "tmux-tokyo-night";
        rev = "7950a7b9c4619feb2a2c3e12918b86740684b71b";
        hash = "sha256-2t8fvAyIWlirsZrNpqgWk00D1mBjPFLcc4e7ZHFP+IQ=";
      };
      rtpFilePath = "tmux-tokyo-night.tmux";
    };
    tokyo-night = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tokyo-night-tmux";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "janoamaral";
        repo = "tokyo-night-tmux";
        rev = "c3bc283cceeefaa7e5896878fe20711f466ab591";
        hash = "sha256-3rMYYzzSS2jaAMLjcQoKreE0oo4VWF9dZgDtABCUOtY=";
      };
      rtpFilePath = "tokyo-night.tmux";
    };
  };
in
lib.mkIf cfg.enable {
  # themes.extra.tmux = {
  #   inherit tmuxThumbsRust tmux-thumbs;
  # };

  home.packages = with pkgs; [
    zoxide
    tmuxThumbsRust
    entr
    tmux-sessionizer
    sesh
  ];

  xdg.configFile."sesh/sesh.toml".source = (pkgs.formats.json { }).generate "sesh.toml" {
    default_session = {
      startup_command = "nvim -c ':Telescope find_files'";
    };
    sessions = [
      {
        name = "config";
        path = "~/config";
        startup_command = "nvim flake.nix";
      }
      {
        name = "repos";
        path = "~/repos";
        startup_command = "";
      }
      {
        name = "infra";
        path = "~/repos/mine";
        startup_command = "";
      }
    ];
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";

    # Rather than constraining window size to the maximum size of any client
    # connected to the *session*, constrain window size to the maximum size of any
    # client connected to *that window*. Much more reasonable.
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    mouse = true;
    newSession = false; # use my own shortcut
    secureSocket = true;
    plugins = with tmuxPlugins; [
      { plugin = yank; } # OSC Yank text
      # { plugin = tmux-window-name; }      # smart renaming # having issues
      {
        plugin = resurrect;
        extraConfig = ''
          # Restore vim sessions
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-processes 'nvim psql mysql sqlite3 npm android-studio direnv nix'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          # Continuum: automatically save current session
          set -g @continuum-restore 'on'
        '';
      }
      {
        plugin = thumbs;
        extraConfig = ''
          # tmux-thumbs: copy urls/hashes/regex
          set -g @thumbs-osc52 1
          set -g @thumbs-contrast 1
        '';
      }
      {
        plugin = open;
        extraConfig = ''
          ## open
          set -g @open-S 'https://startpage.com/sp/search?q='
          set -g @open-s 'https://www.duckduckgo.com/search?q='
        '';
      }
      { plugin = sessionist; } # session helper functions/prefixes
      { plugin = autoreload; } # autoreload tmux.conf when updated
      { plugin = jump; } # jump to specific position in terminal
      # { plugin = tmux-power-zoom; extraConfig = ''
      #     # power-zoom: zoom panes in/out
      #     set -g @power_zoom_trigger M-z
      #     set -g @power_zoom_with_prefix 1
      # ''}
      # { plugin = tokyo-night; }
      {
        plugin = logging;
        extraConfig = ''
          set -g @logging-path "$HOME/.local/state/tmux"
        '';
      }
      {
        plugin = fuzzback;
        extraConfig = ''
          set -g @fuzzback-bind C-Space
        '';
      }
      {
        plugin = extrakto;
        extraConfig = ''
          set -g @extrakto_clip_tool_run tmux_osc52
        '';
      }
      # only works with mullvad vpn client
      # { plugin = mullvad; }
    ];
    terminal = "xterm-256color";
    # set elsewhere
    #shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";
    extraConfig = lib.mkMerge [
      tmuxConfig
      (lib.mkAfter ''
        ### THEME
        set-option -g status-position bottom
        set -g default-terminal "tmux-256color"
        set -as terminal-features ",xterm*:RGB"
        set -as terminal-features ",wezterm:RGB"

        # sizes / posiiton
        set -g status-interval 1
        set -g status-justify left
        set -g status-left-length 20
        set -g status-right-length 140
        ${lib.optionalString cfg.enableTheme ''
          # styles
          highlight="${colors.magenta}"
          foreground="${colors.base05}"
          background="${colors.base00}"
          alternate="${colors.cyan}"
          hostcolor="${cfg.hostcolor}"

          # themes options can't be set via #{}
          # pane number display
          set-option -g display-panes-active-colour $highlight
          set-option -g display-panes-colour $highlight

          # clock
          set-option -wg clock-mode-colour $highlight

          ${builtins.readFile ./theme.conf}
        ''}
      '')
    ];
    #set -g @HIGHLIGHT "${highlight}"
  };
}
