{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.shell.yubikey;
  inherit (lib)
    concatStringsSep
    map
    mapAttrs
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    optionals
    optionalString
    optionalAttrs
    types
    ;
  hasAllowedReaders = cfg.polkit.allowedReaders != [ ];
  hasAllowedUser = cfg.polkit.allowedUser != null;
in
{
  options.khome.shell.yubikey = {
    enable = mkEnableOption "enable yubikey";
    debug = mkEnableOption "enable debug logging";
    graphical = mkEnableOption "enable graphical packages";
    readerPort = mkOption {
      default = null;
      description = "if set, prevent sc-daemon/pcscd from accessing any other yubikey";
      example = "Yubico YubiKey OTP+FIDO+CCID 00 00";
      type = with types; nullOr str;
    };
    sshKeys = mkOption {
      default = [ ];
      description = "ssh keys to add to home-manager gpg-agent";
      type = with types; listOf str;
    };
    enableGpgAgent = mkEnableOption "enable gpg agent integration with yubikeye";
    disableOtherAgents = mkEnableOption "disable gnupg ssh agent";
    setupUser = mkOption {
      default = null;
      type = with types; nullOr str;
      description = "if set, sets up gpg-agent on user via home-manager";
    };
    polkit = {
      enable = mkEnableOption "enable polkit restrictions on yubikey smartcard";
      enableLogging = mkEnableOption "enable logging" // {
        default = cfg.debug;
      };
      allowedUser = mkOption {
        default = null;
        example = "myuser";
        type = with types; nullOr str;
        description = "allow user access to `org.debian.pcsc-lite.access_pcsc`";
      };
      allowedReaders = mkOption {
        default = [ ];
        example = [ "Yubico YubiKey OTP+FIDO+CCID 00 00" ];
        type = with types; listOf str;
        description = "readers allowed to `org.debian.pcsc-lite.access_card`";
      };
    };
  };

  config = mkIf cfg.enable {
    home-manager = mkIf (cfg.setupUser != null) {
      users.${cfg.setupUser} = {
        khome.shell.gpg = {
          enable = mkIf cfg.enableGpgAgent true;
          yubikey = true;
          sshKeys = cfg.sshKeys;
          readerPort = mkIf (cfg.readerPort != null) cfg.readerPort;
        };
      };
    };

    # we prefer user based agents
    programs.gnupg.agent = mkIf cfg.disableOtherAgents {
      enable = mkForce false;
    };
    programs.ssh.startAgent = mkIf cfg.disableOtherAgents {
      enable = mkForce false;
    };

    hardware.gpgSmartcards.enable = true;

    systemd.services.pcscd = mkIf cfg.debug {
      environment.G_MESSAGE_DEBUG = "all";
    };
    services = {
      pcscd.enable = true; # smart card agent
      pcscd.extraArgs = mkIf cfg.debug [ "--debug" ];
      # yubikey udev
      udev.packages = with pkgs; [
        yubikey-personalization
        libu2f-host
        pam_u2f
      ];
    };

    environment.systemPackages =
      [
        pkgs.yubikey-touch-detector
        pkgs.yubikey-manager
      ]
      ++ (optionals cfg.graphical [
        pkgs.yubikey-manager-qt
      ]);

    # enforce access to yubikey
    security.polkit.debug = cfg.polkit.enableLogging;
    security.polkit.extraConfig = mkIf cfg.polkit.enable ''

      ${optionalString cfg.polkit.enableLogging ''
        // logging rule
        polkit.addRule(function(action, subject) {
          polkit.log("action=" + action);
          polkit.log("subject=" + subject);
        });
      ''}

      ${optionalString hasAllowedUser ''
        // allow user access to smartcard
        polkit.addRule(function(action, subject) {
          ${optionalString cfg.debug ''
            polkit.log("Checking pcsc-lite.access_pcsc")
          ''}
          if (
            action.id == "org.debian.pcsc-lite.access_pcsc"
            &&
            subject.user == "${cfg.polkit.allowedUser}"
          ) {
            polkit.log("access pcsc allowed to ${cfg.polkit.allowedUser}");
            return polkit.Result.YES;
          }
        });
      ''}

      ${optionalString (hasAllowedUser || hasAllowedReaders) ''
        // allow user access to smartcard
        polkit.addRule(function(action, subject) {
          if (action.id == "org.debian.pcsc-lite.access_card") {
            reader = action.lookup("reader")
            ${optionalString cfg.debug ''
              polkit.log("Checking pcsc-lite.access_card " + reader)
            ''}
            if (${
              if hasAllowedReaders then
                (concatStringsSep "||" (map (reader: "reader == '${reader}'") cfg.polkit.allowedReaders))
              else
                "true"
            }
                &&
                ${if hasAllowedUser then "subject.user == '${cfg.polkit.allowedUser}'" else "true"}
            ) {
              polkit.log("access card allowed");
              return polkit.Result.YES;
            } else {
              polkit.log("access card denied");
              return polkit.Result.NO;
            }
          }
        });
      ''}
    '';
  };
}
