{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkMerge optional;
  opts = self.inputs.extra-lib.lib.options;
  mcfg = config.khome.desktop.apps.media;
  jcfg = mcfg.jellyfin;

  # -  home.file."${config.xdg.configHome}/mpv-jellyfin-shim/conf.json".text =
  # -    builtins.toJSON {}
  conf = self.inputs.extra-lib.lib.mkDefaults {
    always_transcode = false;
    audio_output = "hdmi";
    auto_play = true;
    check_updates = false;
    client_uuid = "d2519fca-22ff-402e-a2e9-6454b710393c";
    connect_retry_mins = 0;
    direct_paths = false;
    discord_presence = false;
    display_mirroring = false;
    enable_gui = true;
    enable_osc = true;
    fullscreen = true;
    idle_cmd = null;
    idle_cmd_delay = 60;
    idle_when_paused = false;
    ignore_ssl_cert = true; # important
    kb_debug = "~";
    kb_fullscreen = "f";
    kb_kill_shader = "k";
    kb_menu = "c";
    kb_menu_down = "down";
    kb_menu_esc = "esc";
    kb_menu_left = "left";
    kb_menu_ok = "enter";
    kb_menu_right = "right";
    kb_menu_up = "up";
    kb_next = ">";
    kb_pause = "space";
    kb_prev = "<";
    kb_stop = "q";
    kb_unwatched = "u";
    kb_watched = "w";
    lang = null;
    lang_filter = "und,eng,jpn,mis,mul,zxx";
    lang_filter_audio = false;
    lang_filter_sub = false;
    local_kbps = 2147483;
    log_decisions = false;
    media_ended_cmd = null;
    media_key_seek = false;
    media_keys = true;
    menu_mouse = true;
    mpv_ext = false;
    mpv_ext_ipc = null;
    mpv_ext_no_ovr = false;
    mpv_ext_path = null;
    mpv_ext_start = true;
    mpv_log_level = "info";
    notify_updates = false;
    playback_timeout = 30;
    player_name = "kallen";
    pre_media_cmd = null;
    remote_direct_paths = false;
    remote_kbps = 10000;
    sanitize_output = true;
    screenshot_dir = null;
    screenshot_menu = true;
    seek_down = -60;
    seek_h_exact = false;
    seek_left = -5;
    seek_right = 5;
    seek_up = 60;
    seek_v_exact = false;
    shader_pack_custom = false;
    shader_pack_enable = true;
    shader_pack_profile = null;
    shader_pack_remember = true;
    stop_cmd = null;
    stop_idle = false;
    subtitle_color = "#FFFFFFFF";
    subtitle_position = "bottom";
    subtitle_size = 100;
    svp_enable = false;
    svp_socket = null;
    svp_url = "http://127.0.0.1:9901/";
    sync_attempts = 5;
    sync_max_delay_skip = 300;
    sync_max_delay_speed = 50;
    sync_method_thresh = 2000;
    sync_osd_message = true;
    sync_revert_seek = true;
    sync_speed_attempts = 3;
    sync_speed_time = 1000;
    transcode_h265 = false;
    transcode_hi10p = false;
    transcode_to_h265 = false;
    transcode_warning = true;
    use_web_seek = false;
    write_logs = false;
  };
in
{
  options.khome.desktop.apps.media.jellyfin = {
    mpvShim = {
      enable = opts.enable "enable jellyfin-mpv-shim";
      enableConfig = opts.enable "enable setting config via nix";
      config = opts.raw { } "set jellyfin-mpv-shim config";
    };
    mediaPlayer = opts.enable "add jellyfin-media-player";
  };

  config = mkMerge [
    (mkIf mcfg.enable {
      khome.desktop.apps.media.jellyfin.mpvShim.config = conf;
      home.packages =
        [ ]
        ++ (optional jcfg.mpvShim.enable pkgs.jellyfin-mpv-shim)
        ++ (optional jcfg.mediaPlayer pkgs.jellyfin-media-player);
      xdg.configFile = mkIf jcfg.mpvShim.enable {
        "mpv-jellyfin-shim/conf.json".text = builtins.toJSON jcfg.mpvShim.config;
      };
    })
  ];
}
