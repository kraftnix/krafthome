args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.khome.shell.xdg;
  homeDir = "~";
  xdgBase = "${homeDir}/xdg";
  sv = config.home.sessionVariables;
in
{
  options.khome.shell.xdg = {
    enable = mkEnableOption "enable xdg-ninja style remapping";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      # XDG-NINJA hacks
      HISTFILE = "${sv.XDG_STATE_HOME}/bash/history"; # bash history
      CALCHISTFILE = "${sv.XDG_CACHE_HOME}/calc_history"; # calc
      CARGO_HOME = "${sv.XDG_DATA_HOME}/cargo"; # rust/cargo
      GO_PATH = "${sv.XDG_DATA_HOME}/go"; # go packages
      GRADLE_USER_HOME = "${sv.XDG_DATA_HOME}/gradle"; # gradle
      IPYTHONDIR = "${sv.XDG_CONFIG_HOME}/ipython"; # ipython
      JUPYTER_CONFIG_DIR = "${sv.XDG_CONFIG_HOME}/jupyter"; # jpuyter
      KDEHOME = "${sv.XDG_CONFIG_HOME}/kde"; # kde
      LESSHISTFILE = "${sv.XDG_CACHE_HOME}/less/history"; # less
      MPLAYER_HOME = "${sv.XDG_CONFIG_HOME}/mplayer"; # MPlayer
      NODE_REPL_HISTORY = "${sv.XDG_DATA_HOME}/node_repl_history"; # Node
      NPM_CONFIG_GLOBALCONFIG = "${sv.XDG_CONFIG_HOME}/npmrc"; # NPM
      ERRFILE = "${sv.XDG_CACHE_HOME}/X11/xsession-errors"; # X11
    };

    # NPM xdg workaround
    xdg.configFile."npm/npmrc".text = ''
      prefix=${sv.XDG_DATA_HOME}/npm
      cache=${sv.XDG_CACHE_HOME}/npm
      tmp=/run/user/`id -u`/npm
      init-module=${sv.XDG_CONFIG_HOME}/npm/config/npm-init.js
    '';
    # python history for repl
    xdg.configFile."python/pythonrc".text = ''
      import os
      import atexit
      import readline

      history = os.path.join(os.environ['XDG_CACHE_HOME'], 'python_history')
      try:
      readline.read_history_file(history)
      except OSError:
      pass

      def write_history():
      try:
      readline.write_history_file(history)
      except OSError:
      pass

      atexit.register(write_history)
    '';

    #fonts.fontconfig.enable = true;
    xdg = {
      enable = true;
      cacheHome = "${xdgBase}/.cache";
      configHome = "~/.config";
      dataHome = "~/.local/share";
      # mime.enable = true;
      # mimeApps = {};
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${xdgBase}/desktop";
        documents = "${xdgBase}/documents";
        download = "${xdgBase}/downloads";
        music = "${xdgBase}/music";
        pictures = "${xdgBase}/pictures";
        publicShare = "${xdgBase}/public";
        templates = "${xdgBase}/templates";
        videos = "${xdgBase}/videos";
      };
    };
  };
}
