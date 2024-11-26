args:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.khome.shell.gpg;
  inherit (lib)
    mapAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
in
{
  options.khome.shell.gpg = {
    enable = mkEnableOption "enable gpg-agent with ssh integration" // {
      default = cfg.sshKeys != [ ];
    };
    yubikey = mkEnableOption "diable ccid for yubiky compat";
    sshKeys = mkOption {
      default = [ ];
      description = "limit allowed auth keys via gpg";
      type = with types; listOf str;
    };
    readerPort = mkOption {
      default = null;
      description = "if set, prevent sc-daemon/pcscd from accessing any other yubikey";
      example = "Yubico YubiKey OTP+FIDO+CCID 00 00";
      type = with types; nullOr str;
    };
    pinentryPackage = mkOption {
      default = pkgs.pinentry-curses;
      description = "";
      type = types.package;
      example = pkgs.pinentry-gnome3;
    };
    defaultTimeout = mkOption {
      default = 34560000;
      type = types.int;
      description = "default timeout + cache for gpg agent";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      ssh.enable = mkDefault true;
      gpg = {
        enable = true;
        scdaemonSettings =
          (optionalAttrs cfg.yubikey {
            # for yubikey
            # see https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
            disable-ccid = true;
          })
          // (optionalAttrs (cfg.readerPort != null) {
            reader-port = cfg.readerPort;
          });
      };
    };

    services.gpg-agent =
      mapAttrs (_: mkDefault) {
        enable = true;
        enableSshSupport = true;
        enableExtraSocket = true;
        enableScDaemon = true;
        inherit (cfg) pinentryPackage;
      }
      // (optionalAttrs (cfg.sshKeys != [ ]) {
        inherit (cfg) sshKeys;
      })
      // {
        defaultCacheTtl = cfg.defaultTimeout;
        defaultCacheTtlSsh = cfg.defaultTimeout;
        maxCacheTtl = cfg.defaultTimeout;
        maxCacheTtlSsh = cfg.defaultTimeout;
      };
  };
}
