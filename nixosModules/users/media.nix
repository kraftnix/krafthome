{
  config,
  lib,
  ...
}: let
  cfg = config.khome.users.media;
  inherit (config._module.args) hmProfiles; # remove once all home profiles are ported to modules
  inherit
    (lib)
    flatten
    mkEnableOption
    mkOption
    mkIf
    optional
    optionals
    types
    ;
in {
  options.khome.users.media = {
    enable = mkEnableOption "enable media user";
    userName = mkOption {
      type = types.str;
      default = "media";
      description = "actual system username";
    };
    fullGraphical = mkEnableOption "enable full graphical profile";
    addToWheel = mkEnableOption "add to wheel group";
    extraGroups = mkOption {
      description = "extra groups to add user to";
      default = [];
      type = with types; listOf str;
    };
    keyFiles = mkOption {
      description = "pubkey files to add to openssh authorized";
      default = [];
      type = with types; listOf path;
    };
    uid = mkOption {
      type = types.int;
      default = 1100;
      description = "media user uid";
    };
    hashedPassword = mkOption {
      type = types.str;
      default = "$6$UpKEXaKM$WRg6Hsf6BkaAX6iF3/ODJBW1fG.PCDxTXlnvTCLQlIfmczjuACmjm4T2rPWvpPA.RxG2.0ClkA1zaFtKCX13x.";
      description = "default media password";
    };
    home = mkOption {
      type = types.raw;
      default = {};
      description = "home-manager configuration to pass through";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${cfg.userName} = {...}: {
      imports =
        flatten [
          cfg.home
        ]
        ++ (optionals cfg.fullGraphical [
          hmProfiles.desktop.wayfire
          hmProfiles.desktop.tokyo-night
        ]);
      khome.roles.basic.enable = true;

      khome.nushell.enable = true;
      khome.shell.core-tools.enable = true;
      khome.shell.misc.enable = true;
      khome.shell.starship.enable = true;
      khome.shell.tmux.enable = true;

      khome.desktop.misc.enable = true;
      khome.browsers.firefox.enable = true;
      khome.browsers.tor.enable = true;
      khome.misc.sound.enable = true;
      khome.misc.keepass.enable = true;

      home.stateVersion = "22.05";
    };

    # System user config
    users.users.${cfg.userName} = {
      inherit (cfg) uid hashedPassword;
      isNormalUser = true;
      extraGroups = ["tty"] ++ (optional cfg.addToWheel "wheel") ++ cfg.extraGroups;
      openssh.authorizedKeys.keyFiles = cfg.keyFiles;
    };
  };
}
