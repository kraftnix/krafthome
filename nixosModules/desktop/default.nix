{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.khome.desktop;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  imports = [
    ./disable-caps-tty.nix
    ./flatpak.nix
    ./gdm.nix
    ./gnome-polkit.nix
    ./hyprland.nix
    ./plasma/full.nix
    ./printing.nix
    ./sddm.nix
    ./sway.nix
    ./wifi.nix
  ];

  options.khome.desktop = {
    enable = mkEnableOption "enable basic desktop integration";
    enableGnomeCompat = mkEnableOption "enable compat settings for gnome";
    keyboardLayout = mkOption {
      default = "gb";
      type = types.str;
      description = "default keyboard layout";
    };
    extraXdgPortals = mkOption {
      default = [
        pkgs.xdg-desktop-portal-gtk
      ];
      type = types.listOf types.package;
      description = "extra XDG portals";
    };
    tuigreet.enable = mkEnableOption "enable tuigreet default setup";
  };

  config = mkIf cfg.enable {
    khome.tuigreet = mkIf cfg.tuigreet.enable {
      enable = true;
      enableWaylandEnvs = cfg.hyprland.enable || cfg.sway.enable;
      sessions = {
        hyprland.enable = cfg.hyprland.enable;
        sway.enable = cfg.sway.enable;
        zsh.enable = true;
      };
    };
    services.dbus = mkIf cfg.enableGnomeCompat {
      packages = with pkgs; [
        # needed for GNOME services outside of GNOME Desktop
        grc
        gnome.gnome-settings-daemon
      ];
    };
    environment.systemPackages = with pkgs; [ xorg.xeyes ];
    services.xserver = {
      enable = true;
      xkb.layout = cfg.keyboardLayout;
    };
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      xdgOpenUsePortal = true;
      extraPortals = cfg.extraXdgPortals;
    };
  };
}
