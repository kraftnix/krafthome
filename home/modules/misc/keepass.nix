args: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.khome.misc.keepass;
  inherit (pkgs.lib.khome) toggleApp;
  swayMain = !config.programs.hyprland.isMain;
in {
  options.khome.misc.keepass = {
    enable = mkEnableOption "enable keepassxc integration";
    enableSwayKeybinds =
      mkEnableOption "enable keepassxc integration"
      // {
        # default = config.khome.sway.enable;
        default = true;
      };
    package = mkOption {
      default = pkgs.keepassxc;
      description = "keepassxc package to add to home packages";
      type = types.package;
    };
    firejail = {
      enable = mkEnableOption "enable firejail" // {default = config.home.firejail.enable;};
      enableYubikey = mkEnableOption "enable yubikey usage firejail";
      args = mkOption {
        default = {};
        type = with types; attrsOf raw;
        description = "extra args to add to `provision.security.wrappers.keepassxc.firejail`";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (!cfg.firejail.enable) [cfg.package];

    provision.security.wrappers.keepassxc = {
      enable = mkDefault cfg.firejail.enable;
      package = cfg.package;
      firejail = mkMerge [
        {
          enable = mkDefault cfg.firejail.enable;
          desktop = "${cfg.package}/share/applications/org.keepassxc.KeePassXC.desktop";
          protocol = mkIf cfg.firejail.enableYubikey ["netlink,unix"];
          ignore = mkIf cfg.firejail.enableYubikey ["private-dev"];
        }
        cfg.firejail.args
      ];
    };

    wayland.windowManager.sway.config = mkIf cfg.enableSwayKeybinds {
      window.commands = [
        {
          criteria = {app_id = "KeePassXC -*";};
          command = "floating";
        }
        {
          criteria = {app_id = "KeePassXC";};
          #command = "mark keepass, floating enable, move scratchpad";
          command = "mark 12-keepass, move to workspace 12-keepass";
        }
      ];
      keybindings."$mod+p" = lib.mkOverride 250 (toggleApp "12-keepass");
    };
    programs.waybar.settings.mainbar."sway/workspaces".format-icons."12-keepass" = lib.mkIf swayMain "🔐";
  };
}
