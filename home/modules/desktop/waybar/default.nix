args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.desktop.waybar;
  mkStrOption =
    default: description:
    mkOption {
      inherit description default;
      type = types.str;
    };
  hyprlandEnable = cfg.wm == "hyprland";
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "waybar" "systemd" "enable" ]
      [ "programs" "waybar" "systemd" "enable" ]
    )
  ];

  options.khome.desktop.waybar = {
    enable = mkEnableOption "enable waybar integration";
    colorsRelPath = mkStrOption ".config/waybar/colors.css" "path to place `colors.css` relative to home";
    stylecss = mkStrOption (builtins.readFile ./lightweight.css) "style css file";
    wm = mkStrOption "sway" "window manager to optimise for, `sway` or `hyprland` supported.";
    colors = mkOption {
      default = { };
      type = types.raw;
      description = "lib.base16 color attribute set";
    };
    extraConfig = mkOption {
      default = { };
      type = types.raw;
      description = "extra configuration to merge into mainbar";
    };
  };

  config = mkIf cfg.enable {
    khome.desktop.waybar.colors = mkDefault (config.lib.base16.getColorsH "waybar");
    home.file."${cfg.colorsRelPath}".text = builtins.concatStringsSep "\n" (
      mapAttrsToList (name: value: "@define-color ${name} ${value};") cfg.colors
    );

    programs.hyprland.execOnce = mkIf (!cfg.systemd.enable) {
      waybar = "waybar";
    };
    wayland.windowManager.sway.config.startup = mkIf (!cfg.systemd.enable) [
      {
        always = false;
        command = "waybar";
      }
    ];

    programs.waybar = {
      enable = true;
      # systemd.enable = true;
      style = ''
        @import "/home/${config.home.username}/${cfg.colorsRelPath}";
      ''
      + cfg.stylecss;
      settings.mainbar = mkMerge [
        {
          layer = "top";
          position = "top";
          height = 30;
          modules-left =
            if hyprlandEnable then
              [ "${cfg.wm}/workspaces" ]
            else
              [
                "${cfg.wm}/workspaces"
                "sway/mode"
              ];
          modules-center = [ "clock" ];
          modules-right = [
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "disk"
            "temperature"
            "battery"
            "tray"
          ];
          "${cfg.wm}/workspaces" = {
            disable-scroll = true;
            all-outputs = false;
            format = "{icon}";
          };
          "battery" = {
            format = "{capacity}% {icon}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            states = {
              critical = 15;
              warning = 30;
            };
          };
          "sway/mode" = mkIf (!hyprlandEnable) {
            format = "<span style =\"italic\">{}</span>";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              "activated" = "👁️";
              "deactivated" = "";
            };
          };
          "clock" = {
            # TODO: figure out system-level options in home-manager
            #timezone = config.time.timeZone;
            #locale = config.i18n.defaultLocale;
            #timezone = "Europe/Amsterdam";
            #timezone = "Europe/London";
            locale = "en_GB.UTF-8";
            format = "{:%H:%M:%S}";
            format-alt = "{:%H:%M:%S   %Y-%m-%d}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            interval = 1;
          };
          "cpu" = {
            format = "{usage}% ";
            #tooltip = false;
          };
          "disk" = {
            interval = 30;
            format = "{used} / {total}";
            path = "/";
          };
          "memory" = {
            interval = 10;
            format = "{used:0.1f}G / {total:0.1f}G ";
          };
          "temperature" = {
            thermal-zone = 2;
            # TODO: need to figure out how to change this easily per system
            #hwmon-path = "/sys/class/hwmon/hwmon4/temp1_input";
            critical-threshold = 80;
            format-critical = "<span style=\"bold\"> CRITICAL: {temperatureC}°C {icon}</span>";
            format = " {temperatureC}°C {icon}";
            format-icons = [
              ""
              ""
              ""
            ];
          };
          #"backlight" = {
          #  device = "acpi_video1";
          #  format = "{percent}% {icon}";
          #  format-icons = [ "" "" ];
          #};
          "network" = {
            # "interface" = "wlp2*", // (Optional) To force the use of this interface
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ifname} = {ipaddr}/{cidr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname} = {ipaddr}/{cidr}";
          };
          "pulseaudio" = {
            scroll-step = 1;
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };
          "tray" = {
            icon-size = 21;
            spacing = 10;
          };
        }
        cfg.extraConfig
      ];
    };
  };
}
