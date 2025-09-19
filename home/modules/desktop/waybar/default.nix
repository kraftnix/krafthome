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
  hyprlandEnable = config.programs.hyprland.enable;
  niriEnable = config.programs.niri.enable;
  swayEnable = config.wayland.windowManager.sway.enable;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "waybar" "systemd" "enable" ]
      [ "programs" "waybar" "systemd" "enable" ]
    )
    (lib.mkAliasOptionModule [ "khome" "desktop" "waybar" "style" ] [ "programs" "waybar" "style" ])
    (lib.mkAliasOptionModule
      [ "khome" "desktop" "waybar" "settings" ]
      [ "programs" "waybar" "settings" ]
    )
  ];

  options.khome.desktop.waybar = {
    enable = mkEnableOption "enable waybar integration";
    workspacesConfig = mkOption {
      description = "Default options to set in <wm>/workspaces";
      default = {
        disable-scroll = false;
        all-outputs = true;
        format = "{icon}";
      };
      type = types.raw;
    };
    colors = mkOption {
      default = { };
      type = types.raw;
      description = "lib.base16 color attribute set";
    };
    extraCss = mkOption {
      description = "Extra css to append to {programs.waybar.style}";
      default = "";
      type = types.str;
    };
    extraConfig = mkOption {
      default = { };
      type = types.raw;
      description = "extra configuration to merge into mainbar";
    };
  };

  config = mkIf cfg.enable {

    programs.hyprland.execOnce = mkIf (!cfg.systemd.enable) {
      waybar = "waybar";
    };
    wayland.windowManager.sway.config.startup = mkIf (!cfg.systemd.enable) [
      {
        always = false;
        command = "waybar";
      }
    ];

    stylix.targets.waybar.enable = lib.mkDefault true;
    programs.waybar = {
      enable = true;
      systemd.enable = lib.mkDefault true;
      style = lib.mkAfter cfg.extraCss;
      settings.mainbar = mkMerge [
        {
          layer = "top";
          position = "top";
          height = 30;
          modules-left =
            [ ]
            ++ (lib.optional hyprlandEnable "hyprland/workspaces")
            ++ (lib.optional niriEnable "niri/workspaces")
            ++ (lib.optionals swayEnable [
              "sway/workspaces"
              "sway/mode"
            ]);
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
          "niri/workspaces" = mkIf niriEnable cfg.workspacesConfig;
          "hyprland/workspaces" = mkIf hyprlandEnable cfg.workspacesConfig;
          "sway/workspaces" = mkIf swayEnable cfg.workspacesConfig;
          "sway/mode" = mkIf swayEnable {
            format = "<span style =\"italic\">{}</span>";
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
