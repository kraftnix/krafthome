args@{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  ykmanBin = "${pkgs.yubikey-manager}/bin/ykman";
  powerOffMode = ''
    bindsym $mod+o exec --no-startup-id ${ykmanBin} oath code | rofi -dmenu -p "OTP" |  awk '{split($0,a," "); print a[1]}' | xargs -ro ${ykmanBin} oath code | awk '{split($0,b," "); print b[2]}' | wl-copy --trim-newline
  '';
  inherit (pkgs.lib.khome) toggleApp wrapSwayrLog;
in
#{ inputs, self, ... }:
{
  home.packages = with pkgs; [
    # display / lockscreen
    swayidle # autolock
    wdisplays # display management
    wl-clipboard # clipboard mgmt

    # screenshots/recording
    sway-contrib.grimshot # screenshots
    flameshot
    fuzzel # rofi-like
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    # set this in tuigreet to not clash
    # XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    NIXOS_OZONE_WL = "1"; # sets all electron apps to use Wayland/Ozone
  };

  xdg.configFile."sway/colorscheme".source = config.lib.base16.getCustomTemplate "sway" {
    repo = "sway";
    templateName = "colors.mustache";
  };
  imports = [
    ./core.nix
    ./extended.nix
    ./gaps.nix
    ./keybindings.nix
    #(import ./swayr.nix std)
    ./swayr.nix
    ./lock_mode.nix
  ];
  xdg.configFile."sway/env".text = concatStringsSep "\n" (
    mapAttrsToList (env: val: "${env}=${toString val}") config.home.sessionVariables
  );
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false; # for now, breaks with colorscheme variables
    systemd.enable = true;
    swaynag.enable = true;
    #extraConfig = config.gtk.gSettings
    extraConfig = powerOffMode;
    extraConfigEarly = mkBefore ''
      set $mod ${mod}
    '';
    extraOptions = [ "--unsupported-gpu" ];
    #extraSessionCommands = '' export GTK_THEME=${theme.name} '';
    #wrapperFeatures.gtk = config.gtk.options.enable;
    wrapperFeatures.gtk = true;
    config = {
      input = {
        "*" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
        };
      };
      menu = "fuzzel --show-actions";
      keybindings = mapAttrs (n: mkOptionDefault) {
        # screenshot
        Print = "exec flameshot gui";
        "${mod}+Print" = "exec grimshot copy area";
        "${mod}+Shift+Print" = "exec grimshot save screen";
        "${mod}+Shift+n" = "move scratchpad, scratchpad show, resize set 1912 1043, move position 4 4";
        "${mod}+g" = "exec rofi -show emoji -modi emoji ";
        # "${mod}+d" = "exec fuzzel --show-actions";
        # "${mod}+Shift+d" = ''exec "rofi -show-icons -modi ssh,drun,filebrowser,emoji -show drun"'';

        "${mod}+Shift+d" = "exec eww open system-menu --toggle";
        "${mod}+Shift+r" = "exec ${pkgs.writeScript "reload_eww" ''
          eww close bar
          swaymsg reload
          eww reload
          eww open bar
        ''}";

        "${mod}+a" = wrapSwayrLog "switch-window";
        "${mod}+Shift+a" = wrapSwayrLog "switch-workspace-or-window";

        "${mod}+period" = "workspace next";
        "${mod}+comma" = "workspace prev";
      };
      startup = [
        {
          command = "systemctl --user daemon-reload";
          always = true;
        }
        {
          command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP";
          always = true;
        }
        { command = "exec eww daemon"; }
        (mkIf (config.services.mako.enable) {
          command = "exec mako";
          always = true;
        })
        (mkIf (config.programs.waybar.enable && config.programs.waybar.systemd.enable) {
          command = "systemctl --user restart waybar";
          always = true;
        })
        (mkIf (config.services.kanshi.enable) {
          command = "systemctl --user restart kanshi";
          always = true;
        })
        { command = "exec env RUST_BACKTRACE=1 RUST_LOG=swayr=debug swayrd > /tmp/swayrd.log 2>&1"; }
        #{ command = "exec yubikey-touch-detector --libnotify"; always = true; } # is shit
        # {
        #   #always = true;
        #   command = ''
        #     exec swayidle -w \
        #       timeout 300 'swaylock -f' \
        #         timeout 300 'swaymsg "output * dpms off"' \
        #           resume 'swaymsg "output * dpms on"' \
        #             before-sleep 'swaylock -f'
        #   '';
        # }
      ];
      # waybar is configured separately
      bars =
        [ ]
        ++ (with config.programs.waybar; optional (enable && !systemd.enable) { command = "waybar"; })
        ++ [
          { command = "eww daemon"; }
        ];
    };
  };

  /*
    systemd.user.services.wallpaper-change = {
    Unit = {
    After = [ "graphical.target" ];
    Description = "periodically change wallpaper";
    };
    Service.ExecStart = "${pkgs.wallutils}/bin/setrandom ${config.themes.extra.wallpaperDir}/*";
    Install.WantedBy = [ "default.target" ];
    };
    systemd.user.timers.wallpaper-change = {
    Unit = {
    Description = "Update Wallpaper";
    PartOf = [ "wallpaper-change.service" ];
    };
    Timer = {
    OnUnitActiveSec = "15sec";
    Unit = "wallpaper-change.service";
    };
    Install.WantedBy = [ "timers.target" ];
    };
  */
}
