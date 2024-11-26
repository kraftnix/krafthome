{
  self,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  super = "<super>";
in
{
  home.packages = with pkgs; [
    # display / lockscreen
    swayidle # autolock
    wdisplays # display management
    kanshi # automatic display management
    wl-clipboard # clipboard mgmt

    # screenshots/recording
    sway-contrib.grimshot # screenshots
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    XDG_CURRENT_DESKTOP = lib.mkForce "wayfire";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
  };

  programs.wayfire = {
    enable = true;
    settings = {
      input = {
        xkb_layout = "gb";
        xkb_options = "caps:escape";
        cursor_size = 40;
      };
      core = {
        autostart_wf_shell = false;
        #gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
        #qtgreet = "${pkgs.greetd.qtgreet}/bin/qtgreet -l";
        #dm = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l && wayland-logout";
      };
    };
    extraPlugins = [ "blur" ];
    bindings = {
      launcher.command = "rofi -show-icons -modi drun,calc,filebrowser -show drun";
      volume_up.command = "${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%";
      volume_down.command = "${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%";
      mute.command = "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle";
      playpause.command = "${pkgs.playerctl}/bin/playerctl play-pause";
      next.command = "${pkgs.playerctl}/bin/playerctl next";
      prev.command = "${pkgs.playerctl}/bin/playerctl previous";
    };
  };
}
